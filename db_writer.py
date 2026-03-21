"""
================================================================================
  EduMetrics Simulator — db_writer.py

  All writes to edumetrics_client on behalf of the simulator.
  Sits in the same folder as connection.py.

  Public API:
    advance_week(seed=None)       -> dict   advance DB by one week
    rollback_to_week(target)      -> dict   delete all data beyond target week
    get_db_status()               -> dict   current week + row counts + events

  MySQL user: simulator_app
    SELECT          on all tables
    INSERT, DELETE  on the 6 transactional tables
    UPDATE          on sim_state only
================================================================================
"""

import sys
import os
import random
from datetime import date, timedelta, datetime

# Same-package import — connection.py is in the same folder
sys.path.insert(0, os.path.dirname(__file__))
from connection import query, get_conn

# ── CONSTANTS ─────────────────────────────────────────────────────────────────
MIDTERM_WEEK       = 8
ENDTERM_WEEK       = 16
MIDTERM_RESULT_WEEK = MIDTERM_WEEK  + 2   # results published 2 weeks after exam
ENDTERM_RESULT_WEEK = ENDTERM_WEEK + 2

# ── ARCHETYPE BEHAVIOUR PROFILES ──────────────────────────────────────────────
# Used only inside this file to generate realistic row data.
# Never written to the DB.
ARCHETYPES = {
    "high_performer": {
        "attend": 91, "sub": 96, "lat": -52, "qual": 88,
        "plag":  2,  "qa": 95,  "qs": 87,  "lib": 3.8,
        "fade":  0,  "crisis": None, "bloom": None,
    },
    "consistent_avg": {
        "attend": 78, "sub": 82, "lat": -20, "qual": 68,
        "plag":  8,  "qa": 74,  "qs": 65,  "lib": 1.9,
        "fade":  0,  "crisis": None, "bloom": None,
    },
    "late_bloomer": {
        "attend": 60, "sub": 55, "lat":  -5, "qual": 55,
        "plag": 12,  "qa": 52,  "qs": 48,  "lib": 0.9,
        "fade":  0,  "crisis": None, "bloom": 10,
    },
    "slow_fader": {
        "attend": 82, "sub": 80, "lat": -22, "qual": 70,
        "plag":  9,  "qa": 72,  "qs": 63,  "lib": 1.6,
        "fade": -2.4,"crisis": None, "bloom": None,
    },
    "crammer": {
        "attend": 64, "sub": 52, "lat":  -3, "qual": 58,
        "plag": 18,  "qa": 38,  "qs": 51,  "lib": 0.4,
        "fade":  0,  "crisis": None, "bloom": None,
    },
    "crisis_student": {
        "attend": 82, "sub": 81, "lat": -24, "qual": 72,
        "plag":  6,  "qa": 76,  "qs": 68,  "lib": 2.1,
        "fade":  0,  "crisis":  9, "bloom": None,
    },
    "silent_disengager": {
        "attend": 74, "sub": 75, "lat": -14, "qual": 62,
        "plag": 14,  "qa": 32,  "qs": 44,  "lib": 0.1,
        "fade":  0,  "crisis": None, "bloom": None,
    },
}

# Attendance shift per semester (class personality)
SEM_ATT_MOD = {1: 2, 3: -3, 5: -9}

# ── SMALL HELPERS ─────────────────────────────────────────────────────────────
def _clamp(v, lo, hi):
    return max(lo, min(hi, v))

def _noisy(v, sigma, lo=0.0, hi=100.0):
    return _clamp(v + random.gauss(0, sigma), lo, hi)

def _week_monday(semester_start, week_num):
    """Return the Monday date of week_num (1-indexed) within a semester."""
    start = date.fromisoformat(str(semester_start))
    return start + timedelta(weeks=week_num - 1)

def _score_to_grade(pct):
    if pct >= 90: return "O"
    if pct >= 80: return "A+"
    if pct >= 70: return "A"
    if pct >= 60: return "B+"
    if pct >= 50: return "B"
    if pct >= 40: return "C"
    return "F"

def _arc(archetype_str):
    """Return archetype profile, falling back to consistent_avg if unknown."""
    return ARCHETYPES.get(archetype_str, ARCHETYPES["consistent_avg"])

def _week_modifiers(week, semester):
    """Additive behaviour modifiers for semester calendar events."""
    m = {"attend": 0, "lat_add": 0.0, "lib_add": 0.0, "quiz_drop": 0}
    if week == 7:
        m["lib_add"] += 2.5; m["lat_add"] += 6;  m["attend"] -= 2
    if week == MIDTERM_WEEK:
        m["attend"]  -= 5;   m["quiz_drop"] -= 10
    if week == MIDTERM_WEEK + 1:
        m["attend"]  -= 4
    if week == 14:
        m["lib_add"] += 3.0; m["lat_add"] += 8
    if week == ENDTERM_WEEK:
        m["attend"]  -= 6
    if semester >= 5 and 8 <= week <= 13:
        m["attend"]  -= 5
    return m


# ── DB READ HELPERS ───────────────────────────────────────────────────────────
def _get_sim_state():
    rows = query("SELECT current_week, semester_start FROM sim_state WHERE id = 1")
    if not rows:
        raise RuntimeError("sim_state is empty — run schema SQL first.")
    return rows[0]

def _get_classes():
    return query("SELECT class_id, semester FROM classes")

def _get_students(class_id):
    return query(
        "SELECT student_id, archetype FROM students WHERE class_id = %s",
        (class_id,)
    )

def _get_subjects(class_id):
    return query(
        """SELECT s.subject_id
           FROM   subjects s
           JOIN   class_subjects cs ON s.subject_id = cs.subject_id
           WHERE  cs.class_id = %s""",
        (class_id,)
    )

def _get_assignments_due(class_id, week):
    return query(
        """SELECT assignment_id, subject_id, max_marks
           FROM   assignment_definitions
           WHERE  class_id = %s AND due_week = %s""",
        (class_id, week)
    )

def _get_active_load(class_id, week):
    rows = query(
        """SELECT COUNT(*) AS n FROM assignment_definitions
           WHERE class_id = %s AND due_week = %s""",
        (class_id, week)
    )
    return rows[0]["n"]

def _get_quizzes(class_id, week):
    return query(
        """SELECT quiz_id, subject_id, max_marks
           FROM   quiz_definitions
           WHERE  class_id = %s AND scheduled_week = %s""",
        (class_id, week)
    )

def _get_exam_schedule(class_id, exam_week):
    return query(
        """SELECT schedule_id, subject_id, exam_type, max_marks
           FROM   exam_schedule
           WHERE  class_id = %s AND scheduled_week = %s""",
        (class_id, exam_week)
    )

def _get_due_date(assignment_id):
    rows = query(
        "SELECT due_week FROM assignment_definitions WHERE assignment_id = %s",
        (assignment_id,)
    )
    return rows[0]["due_week"] if rows else None

def _week_exists(class_id, week):
    rows = query(
        "SELECT COUNT(*) AS n FROM attendance WHERE class_id = %s AND week = %s",
        (class_id, week)
    )
    return rows[0]["n"] > 0


# ── ROW GENERATORS ────────────────────────────────────────────────────────────
def _build_attendance(students, subjects, class_id, semester, week, wdate):
    ev      = _week_modifiers(week, semester)
    sem_mod = SEM_ATT_MOD.get(semester, 0)
    rows    = []
    for stu in students:
        a = _arc(stu["archetype"])
        base = a["attend"] + sem_mod + ev["attend"]

        if stu["archetype"] == "slow_fader" and week > 4:
            base += a["fade"] * (week - 4)
        if stu["archetype"] == "late_bloomer" and a["bloom"] and week >= a["bloom"]:
            base += 18
        if stu["archetype"] == "crisis_student" and a["crisis"] and week >= a["crisis"]:
            base -= 30
        if stu["archetype"] == "crammer" and week in (7, 14, 15):
            base += 8

        base = _noisy(base, 7, 0, 100)

        for subj in subjects:
            lectures = 3
            s_att    = _clamp(base + random.gauss(0, 5), 0, 100)
            present  = round(lectures * s_att / 100)
            late     = 1 if present < lectures and random.random() < 0.3 else 0
            absent   = max(0, lectures - present - late)
            rows.append((
                stu["student_id"], class_id, subj["subject_id"],
                week, str(wdate), lectures,
                present, absent, late,
                round(present / lectures * 100, 1),
            ))
    return rows


def _build_assignment_submissions(students, assignments, class_id, semester, week):
    sem_start = _get_sim_state()["semester_start"]
    if not assignments:
        return []
    ev          = _week_modifiers(week, semester)
    active_load = _get_active_load(class_id, week)
    rows        = []
    for stu in students:
        a = _arc(stu["archetype"])
        for asn in assignments:
            ws = a["sub"]
            wl = a["lat"] + ev["lat_add"]
            wq = a["qual"]
            wp = a["plag"]

            if stu["archetype"] == "slow_fader" and week > 6:
                ws -= 15; wl += 12; wq -= 10
            if stu["archetype"] == "late_bloomer" and a["bloom"] and week >= a["bloom"]:
                ws += 25; wl -= 10; wq += 15
            if stu["archetype"] == "crisis_student" and a["crisis"] and week >= a["crisis"]:
                ws -= 35; wl += 30; wq -= 25
            if stu["archetype"] == "crammer":
                wl += 15
            if active_load >= 4:
                wl += 8

            submitted = random.random() < _clamp(ws, 0, 100) / 100
            if not submitted:
                rows.append((
                    asn["assignment_id"], stu["student_id"], class_id,
                    "missing", None, None, None, None, 0.0,
                ))
                continue

            latency  = _noisy(wl, 12, -120, 48)
            quality  = _noisy(wq, 10, 15, 100)
            marks    = round(asn["max_marks"] * quality / 100, 2)
            plag     = round(_noisy(wp, 8, 0, 80), 1) if random.random() < 0.15 else 0.0
            is_late  = latency > 0

            sub_dt = None
            due = _get_due_date(asn["assignment_id"])
            if due:
                due_date = _week_monday(sem_start, due)
                sub_dt = str(due_date + timedelta(hours=latency))

            rows.append((
                asn["assignment_id"], stu["student_id"], class_id,
                "late" if is_late else "on_time",
                sub_dt, round(latency, 1), marks, round(quality, 1), plag,
            ))
    return rows


def _build_quiz_submissions(students, quizzes, class_id, semester, week):
    if not quizzes:
        return []
    ev   = _week_modifiers(week, semester)
    rows = []
    for stu in students:
        a = _arc(stu["archetype"])
        for qz in quizzes:
            wqa = a["qa"] + ev["quiz_drop"]
            wqs = a["qs"]

            if stu["archetype"] == "silent_disengager":  wqa -= 20
            if stu["archetype"] == "slow_fader" and week > 6:
                wqa -= 15; wqs -= 12
            if stu["archetype"] == "crisis_student" and a["crisis"] and week >= a["crisis"]:
                wqa -= 35; wqs -= 30
            if stu["archetype"] == "late_bloomer" and a["bloom"] and week >= a["bloom"]:
                wqa += 20; wqs += 18
            if stu["archetype"] == "crammer" and week in (7, 8, 14, 15):
                wqa += 25

            attempted = random.random() < _clamp(wqa, 0, 100) / 100
            if not attempted:
                rows.append((
                    qz["quiz_id"], stu["student_id"], class_id,
                    0, None, None, None,
                ))
                continue

            spct  = _noisy(wqs, 12, 10, 100)
            marks = round(qz["max_marks"] * spct / 100, 2)
            rows.append((
                qz["quiz_id"], stu["student_id"], class_id,
                1, str(datetime.now()), marks, round(spct, 1),
            ))
    return rows


def _build_library_visits(students, class_id, semester, week, wdate):
    ev   = _week_modifiers(week, semester)
    rows = []
    for stu in students:
        a    = _arc(stu["archetype"])
        wlib = a["lib"] + ev["lib_add"]

        if stu["archetype"] == "silent_disengager":
            wlib = max(0, wlib - 0.8)
        if stu["archetype"] == "crisis_student" and a["crisis"] and week >= a["crisis"]:
            wlib = 0.0
        if stu["archetype"] == "crammer" and week in (7, 8, 14, 15, 16):
            wlib += 3.0
        if stu["archetype"] == "late_bloomer" and a["bloom"] and week >= a["bloom"]:
            wlib += 1.2

        visits = max(0, round(random.gauss(wlib, 0.8)))
        rows.append((
            stu["student_id"], class_id,
            week, str(wdate), visits,
        ))
    return rows


def _build_exam_results(students, exams, class_id, semester, result_date):
    if not exams:
        return []
    sem_mod = SEM_ATT_MOD.get(semester, 0)
    rows    = []
    for stu in students:
        for ex in exams:
            base_map = {
                "high_performer":    87,
                "consistent_avg":    68,
                "late_bloomer":      60 if ex["exam_type"] == "midterm" else 75,
                "slow_fader":        72 if ex["exam_type"] == "midterm" else 52,
                "crammer":           55 if ex["exam_type"] == "midterm" else 65,
                "crisis_student":    74 if ex["exam_type"] == "midterm" else 42,
                "silent_disengager": 58,
            }
            base  = base_map.get(stu["archetype"], 65) + sem_mod * 0.3
            base  = _noisy(base, 9, 10, 100)
            marks = round(ex["max_marks"] * base / 100, 2)
            pct   = round(base, 1)
            rows.append((
                ex["schedule_id"], stu["student_id"], class_id,
                marks, ex["max_marks"], pct,
                "P" if pct >= 40 else "F",
                _score_to_grade(pct),
                str(result_date),
            ))
    return rows


# ── PUBLIC: ADVANCE WEEK ──────────────────────────────────────────────────────
def advance_week(seed=None):
    """
    Advance the database by exactly one week.
    Generates data for ALL three classes simultaneously — mirrors a real
    college where the calendar moves forward for everyone at the same time.

    Returns a summary dict:
      { "week": int, "classes": { class_id: { table: row_count } } }
    """
    if seed is not None:
        random.seed(seed)

    state     = _get_sim_state()
    cur_week  = state["current_week"]
    sem_start = state["semester_start"]
    new_week  = cur_week + 1

    if new_week > 18:
        raise ValueError(
            f"Semester complete — already at week {cur_week}. "
            "Use rollback_to_week(0) to reset."
        )

    classes = _get_classes()
    summary = {"week": new_week, "classes": {}}

    conn = get_conn()
    cur  = conn.cursor()

    try:
        conn.start_transaction()

        for cls in classes:
            class_id = cls["class_id"]
            semester = cls["semester"]

            if _week_exists(class_id, new_week):
                print(f"  [{class_id}] week {new_week} already exists — skipping.")
                continue

            students    = _get_students(class_id)
            subjects    = _get_subjects(class_id)
            assignments = _get_assignments_due(class_id, new_week)
            quizzes     = _get_quizzes(class_id, new_week)
            wdate       = _week_monday(sem_start, new_week)
            counts      = {}

            # ── Attendance ────────────────────────────────────────────────
            att = _build_attendance(
                students, subjects, class_id, semester, new_week, wdate)
            cur.executemany(
                """INSERT INTO attendance
                   (student_id, class_id, subject_id, week, week_date,
                    lectures_held, present, absent, late, attendance_pct)
                   VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                att
            )
            counts["attendance"] = len(att)

            # ── Assignment submissions ─────────────────────────────────────
            subs = _build_assignment_submissions(
                students, assignments, class_id, semester, new_week)
            if subs:
                cur.executemany(
                    """INSERT IGNORE INTO assignment_submissions
                       (assignment_id, student_id, class_id, status,
                        submission_date, latency_hours, marks_obtained,
                        quality_pct, plagiarism_pct)
                       VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                    subs
                )
                counts["assignment_submissions"] = len(subs)

            # ── Quiz submissions ───────────────────────────────────────────
            qzs = _build_quiz_submissions(
                students, quizzes, class_id, semester, new_week)
            if qzs:
                cur.executemany(
                    """INSERT IGNORE INTO quiz_submissions
                       (quiz_id, student_id, class_id, attempted,
                        attempt_date, marks_obtained, score_pct)
                       VALUES (%s,%s,%s,%s,%s,%s,%s)""",
                    qzs
                )
                counts["quiz_submissions"] = len(qzs)

            # ── Library visits ─────────────────────────────────────────────
            lib = _build_library_visits(
                students, class_id, semester, new_week, wdate)
            cur.executemany(
                """INSERT IGNORE INTO library_visits
                   (student_id, class_id, week, week_date, physical_visits)
                   VALUES (%s,%s,%s,%s,%s)""",
                lib
            )
            counts["library_visits"] = len(lib)

            # ── Exam results (published 2 weeks after exam) ────────────────
            exam_results_rows = []
            if new_week == MIDTERM_RESULT_WEEK:
                exams = _get_exam_schedule(class_id, MIDTERM_WEEK)
                exam_results_rows = _build_exam_results(
                    students, exams, class_id, semester, wdate)
            elif new_week == ENDTERM_RESULT_WEEK:
                exams = _get_exam_schedule(class_id, ENDTERM_WEEK)
                exam_results_rows = _build_exam_results(
                    students, exams, class_id, semester, wdate)

            if exam_results_rows:
                cur.executemany(
                    """INSERT IGNORE INTO exam_results
                       (schedule_id, student_id, class_id,
                        marks_obtained, max_marks, score_pct,
                        pass_fail, grade, result_date)
                       VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)""",
                    exam_results_rows
                )
                counts["exam_results"] = len(exam_results_rows)

            summary["classes"][class_id] = counts

        # ── Advance sim_state — always last ────────────────────────────────
        cur.execute(
            "UPDATE sim_state SET current_week = %s WHERE id = 1",
            (new_week,)
        )

        conn.commit()
        print(f"  Week {new_week} committed.")

    except Exception as e:
        conn.rollback()
        print(f"  ERROR — rolled back everything. {e}")
        raise

    finally:
        cur.close()
        conn.close()

    return summary


# ── PUBLIC: ROLLBACK ──────────────────────────────────────────────────────────
def rollback_to_week(target_week):
    """
    Delete all transactional data beyond target_week across all classes,
    then reset sim_state.current_week to target_week.

    Wrapped in a single transaction — all deletes succeed together or
    nothing is deleted.

    target_week = 0 wipes all transactional data back to a fresh Week 0.
    """
    state    = _get_sim_state()
    cur_week = state["current_week"]

    if target_week >= cur_week:
        raise ValueError(
            f"target_week ({target_week}) must be less than "
            f"current_week ({cur_week})."
        )
    if target_week < 0:
        raise ValueError("target_week cannot be negative.")

    print(f"  Rolling back week {cur_week} → week {target_week} ...")

    conn = get_conn()
    cur  = conn.cursor()

    try:
        conn.start_transaction()

        cur.execute(
            "DELETE FROM attendance WHERE week > %s",
            (target_week,)
        )
        deleted_att = cur.rowcount

        cur.execute(
            """DELETE sub FROM assignment_submissions sub
               JOIN   assignment_definitions def
                 ON   sub.assignment_id = def.assignment_id
               WHERE  def.due_week > %s""",
            (target_week,)
        )
        deleted_sub = cur.rowcount

        cur.execute(
            """DELETE qs FROM quiz_submissions qs
               JOIN   quiz_definitions qd
                 ON   qs.quiz_id = qd.quiz_id
               WHERE  qd.scheduled_week > %s""",
            (target_week,)
        )
        deleted_qz = cur.rowcount

        cur.execute(
            "DELETE FROM library_visits WHERE week > %s",
            (target_week,)
        )
        deleted_lib = cur.rowcount

        cur.execute(
            "DELETE FROM book_borrows WHERE borrow_week > %s",
            (target_week,)
        )
        deleted_brw = cur.rowcount

        cur.execute(
            """DELETE er FROM exam_results er
               JOIN   exam_schedule es ON er.schedule_id = es.schedule_id
               WHERE  (es.scheduled_week + 2) > %s""",
            (target_week,)
        )
        deleted_ex = cur.rowcount

        cur.execute(
            "UPDATE sim_state SET current_week = %s WHERE id = 1",
            (target_week,)
        )

        conn.commit()

        result = {
            "from_week": cur_week,
            "to_week":   target_week,
            "deleted": {
                "attendance":             deleted_att,
                "assignment_submissions": deleted_sub,
                "quiz_submissions":       deleted_qz,
                "library_visits":         deleted_lib,
                "book_borrows":           deleted_brw,
                "exam_results":           deleted_ex,
            }
        }

        print(f"  Rollback complete.")
        for tbl, n in result["deleted"].items():
            if n:
                print(f"    {tbl:<28} {n} rows deleted")
        print(f"    sim_state reset to week {target_week}")
        return result

    except Exception as e:
        conn.rollback()
        print(f"  ERROR — nothing was changed. {e}")
        raise

    finally:
        cur.close()
        conn.close()


# ── PUBLIC: STATUS ────────────────────────────────────────────────────────────
def get_db_status():
    """
    Return a snapshot of the current database state.
    Used by the Streamlit UI to populate the status panel.
    """
    state = _get_sim_state()
    week  = state["current_week"]

    events = []
    for cls in _get_classes():
        cid = cls["class_id"]
        sem = cls["semester"]

        asn_n = query(
            "SELECT COUNT(*) AS n FROM assignment_definitions "
            "WHERE class_id=%s AND due_week=%s", (cid, week)
        )[0]["n"]
        qz_n  = query(
            "SELECT COUNT(*) AS n FROM quiz_definitions "
            "WHERE class_id=%s AND scheduled_week=%s", (cid, week)
        )[0]["n"]
        ex_n  = query(
            "SELECT COUNT(*) AS n FROM exam_schedule "
            "WHERE class_id=%s AND scheduled_week=%s", (cid, week)
        )[0]["n"]

        if asn_n: events.append(f"{cid}: {asn_n} assignment(s) due")
        if qz_n:  events.append(f"{cid}: {qz_n} quiz(zes)")
        if ex_n:  events.append(f"{cid}: EXAM")

    return {
        "current_week":   week,
        "events_at_current_week": events,
    }




    
