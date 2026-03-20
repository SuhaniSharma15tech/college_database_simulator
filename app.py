import streamlit as st
from db_writer import advance_week, rollback_to_week, get_db_status

# ── PAGE CONFIG ───────────────────────────────────────────────────────────────
st.set_page_config(
    page_title="EduMetrics Simulator",
    page_icon="🗓️",
    layout="wide",
)

# ── SESSION STATE ─────────────────────────────────────────────────────────────
if "log" not in st.session_state:
    st.session_state.log = []

if "confirm_reset" not in st.session_state:
    st.session_state.confirm_reset = False

if "confirm_rollback" not in st.session_state:
    st.session_state.confirm_rollback = None   # stores target week when pending

# ── MILESTONE MAP ─────────────────────────────────────────────────────────────
MILESTONES = {8: "Midterm", 16: "End-term", 18: "Sem end"}

# Event label cleanup — strip class prefix for display
def clean_event(event_str):
    """'CSE_SEM1_A: 2 assignment(s) due'  →  '2 assignments due (Sem 1)'"""
    parts = event_str.split(": ", 1)
    if len(parts) == 2:
        cls_id = parts[0]
        detail = parts[1]
        sem_map = {
            "CSE_SEM1_A": "Sem 1",
            "CSE_SEM3_A": "Sem 3",
            "CSE_SEM5_A": "Sem 5",
        }
        label = sem_map.get(cls_id, cls_id)
        return f"{detail} ({label})"
    return event_str

def add_log(text, week=None, log_type="analysis"):
    from datetime import datetime
    ts = datetime.now().strftime("%H:%M:%S")
    st.session_state.log.insert(0, {
        "ts": ts,
        "text": text,
        "week": week,
        "type": log_type,
    })
    if len(st.session_state.log) > 80:
        st.session_state.log.pop()

def get_events_for_week(week):
    """Get event labels for any arbitrary week (used for timeline tooltips)."""
    from connection import query
    events = []
    classes = query("SELECT class_id FROM classes")
    for cls in classes:
        cid = cls["class_id"]
        sem_map = {"CSE_SEM1_A": "S1", "CSE_SEM3_A": "S3", "CSE_SEM5_A": "S5"}
        short   = sem_map.get(cid, cid)

        asn = query(
            "SELECT COUNT(*) AS n FROM assignment_definitions "
            "WHERE class_id=%s AND due_week=%s", (cid, week)
        )[0]["n"]
        qz  = query(
            "SELECT COUNT(*) AS n FROM quiz_definitions "
            "WHERE class_id=%s AND scheduled_week=%s", (cid, week)
        )[0]["n"]
        ex  = query(
            "SELECT COUNT(*) AS n FROM exam_schedule "
            "WHERE class_id=%s AND scheduled_week=%s", (cid, week)
        )[0]["n"]

        if asn: events.append(f"{asn} asn due ({short})")
        if qz:  events.append(f"{qz} quiz ({short})")
        if ex:  events.append(f"EXAM ({short})")
    return events

def has_events_at(week):
    return bool(get_events_for_week(week))

# ── FETCH CURRENT STATUS ──────────────────────────────────────────────────────
status       = get_db_status()
current_week = status["current_week"]
raw_events   = status["events_at_current_week"]
events       = [clean_event(e) for e in raw_events]

# How many weeks have data (i.e. attendance rows exist)
from connection import query as db_query
analysed_weeks = []
for w in range(1, 19):
    rows = db_query(
        "SELECT COUNT(*) AS n FROM attendance WHERE week = %s", (w,)
    )
    if rows[0]["n"] > 0:
        analysed_weeks.append(w)

last_analysed   = max(analysed_weeks) if analysed_weeks else 0
pending_count   = current_week - last_analysed

# ── HEADER ────────────────────────────────────────────────────────────────────
header_col, reset_col = st.columns([4, 1])
with header_col:
    st.subheader("EduMetrics — DB Simulator")
    st.caption("Dev mode only — simulates the college database state week by week")
with reset_col:
    if st.button("Reset to Week 0", type="secondary", use_container_width=True):
        st.session_state.confirm_reset = True

# ── RESET CONFIRMATION ────────────────────────────────────────────────────────
if st.session_state.confirm_reset:
    with st.container(border=True):
        st.warning(
            f"This will delete ALL transactional data (weeks 1–{current_week}) "
            "and reset sim_state to week 0. This cannot be undone."
        )
        c1, c2, _ = st.columns([1, 1, 4])
        if c1.button("Yes, reset", type="primary"):
            try:
                rollback_to_week(0)
                add_log("DB reset to week 0 — all transactional data cleared.", log_type="rollback")
                st.session_state.confirm_reset = False
                st.rerun()
            except Exception as e:
                st.error(f"Reset failed: {e}")
        if c2.button("Cancel"):
            st.session_state.confirm_reset = False
            st.rerun()

# ── ROLLBACK CONFIRMATION ─────────────────────────────────────────────────────
if st.session_state.confirm_rollback is not None:
    target = st.session_state.confirm_rollback
    with st.container(border=True):
        st.warning(
            f"Roll back to **Week {target}**? "
            f"All data from week {target + 1} to week {current_week} "
            "will be permanently deleted from the database."
        )
        c1, c2, _ = st.columns([1, 1, 4])
        if c1.button("Yes, roll back", type="primary"):
            try:
                result = rollback_to_week(target)
                deleted = sum(result["deleted"].values())
                add_log(
                    f"Rolled back week {current_week} → week {target}. "
                    f"{deleted} rows deleted.",
                    week=target,
                    log_type="rollback",
                )
                st.session_state.confirm_rollback = None
                st.rerun()
            except Exception as e:
                st.error(f"Rollback failed: {e}")
        if c2.button("Cancel", key="cancel_rb"):
            st.session_state.confirm_rollback = None
            st.rerun()

# ── STAT CARDS ────────────────────────────────────────────────────────────────
c1, c2, c3, c4 = st.columns(4)
c1.metric("DB at week",       current_week)
c2.metric("Last analysed",    last_analysed if last_analysed else "—")
c3.metric("Weeks analysed",   len(analysed_weeks))
c4.metric("Pending analysis", pending_count)

# ── CURRENT STATE ─────────────────────────────────────────────────────────────
with st.container(border=True):
    st.write("**CURRENT STATE**")

    milestone = MILESTONES.get(current_week, "")
    state_label = f"W{current_week}" if current_week > 0 else "Pre-semester"
    if milestone:
        state_label += f" + {milestone}"

    st.markdown(f"### {state_label}")

    if events:
        cols = st.columns(len(events))
        for i, ev in enumerate(events):
            cols[i].info(ev)
    elif current_week == 0:
        st.caption("No data yet — click a week below to begin.")
    else:
        st.caption("Regular week — attendance only.")

# ── SEMESTER TIMELINE ─────────────────────────────────────────────────────────
with st.container(border=True):
    legend_col, _ = st.columns([3, 1])
    with legend_col:
        st.write("**SEMESTER TIMELINE — CLICK ANY WEEK**")

    # Legend
    lc1, lc2, lc3, lc4 = st.columns([1, 1, 1, 4])
    lc1.markdown("🟦 Current")
    lc2.markdown("🟩 Analysed")
    lc3.markdown("• Has events")

    # Week buttons — two rows of 9
    row1 = list(range(1, 10))
    row2 = list(range(10, 19))

    for row in [row1, row2]:
        cols = st.columns(len(row))
        for i, w in enumerate(row):
            is_current  = (w == current_week)
            is_analysed = (w in analysed_weeks)
            is_milestone= (w in MILESTONES)
            has_ev      = has_events_at(w)

            # Build button label
            dot    = " •" if has_ev else ""
            label  = f"**{w}**{dot}" if is_milestone else f"{w}{dot}"

            # Button type
            btn_type = "primary" if is_current else "secondary"

            # Tooltip
            tip_parts = []
            if is_milestone:
                tip_parts.append(MILESTONES[w])
            ev_list = get_events_for_week(w)
            tip_parts.extend(ev_list)
            tip = " · ".join(tip_parts) if tip_parts else f"Week {w}"

            if cols[i].button(
                label,
                key=f"week_btn_{w}",
                type=btn_type,
                use_container_width=True,
                help=tip,
            ):
                if w < current_week:
                    # Going backwards — trigger rollback confirmation
                    st.session_state.confirm_rollback = w
                    st.rerun()
                elif w == current_week:
                    pass   # already here
                else:
                    # Going forward — advance week by week
                    try:
                        weeks_to_advance = w - current_week
                        for step in range(weeks_to_advance):
                            target_w = current_week + step + 1
                            summary  = advance_week()
                            ev_list  = get_events_for_week(target_w)
                            ev_str   = ", ".join(ev_list) if ev_list else "Attendance logged"
                            add_log(
                                f"Analysed W{target_w} [{ev_str}]",
                                week=target_w,
                                log_type="analysis",
                            )
                        st.rerun()
                    except Exception as e:
                        st.error(f"Could not advance: {e}")

    # Milestone labels below
    ml_cols = st.columns(18)
    for w, label in MILESTONES.items():
        ml_cols[w - 1].caption(f"W{w}: {label}")

# ── QUICK JUMP ────────────────────────────────────────────────────────────────
with st.container(border=True):
    st.write("**QUICK JUMP**")
    jc1, jc2, jc3, jc4 = st.columns([2, 1, 1, 1])

    jump_target = jc1.number_input(
        "Go to week", min_value=0, max_value=18,
        value=min(current_week + 1, 18),
        label_visibility="collapsed",
    )
    if jc2.button("Jump", use_container_width=True):
        if jump_target == current_week:
            st.info("Already at this week.")
        elif jump_target < current_week:
            st.session_state.confirm_rollback = jump_target
            st.rerun()
        else:
            try:
                weeks_to_go = jump_target - current_week
                for step in range(weeks_to_go):
                    target_w = current_week + step + 1
                    advance_week()
                    ev_list = get_events_for_week(target_w)
                    ev_str  = ", ".join(ev_list) if ev_list else "Attendance logged"
                    add_log(
                        f"Analysed W{target_w} [{ev_str}]",
                        week=target_w,
                        log_type="analysis",
                    )
                st.rerun()
            except Exception as e:
                st.error(f"Jump failed: {e}")

    if current_week < 18:
        if jc3.button(f"Next week (W{current_week + 1})", use_container_width=True):
            try:
                summary = advance_week()
                new_w   = current_week + 1
                ev_list = get_events_for_week(new_w)
                ev_str  = ", ".join(ev_list) if ev_list else "Attendance logged"
                add_log(f"Analysed W{new_w} [{ev_str}]", week=new_w, log_type="analysis")
                st.rerun()
            except Exception as e:
                st.error(f"Could not advance: {e}")

    if current_week > 0:
        if jc4.button(f"Back to W{current_week - 1}", use_container_width=True):
            st.session_state.confirm_rollback = current_week - 1
            st.rerun()

# ── ANALYSIS & EVENT LOG ──────────────────────────────────────────────────────
with st.container(border=True):
    log_col, clear_col = st.columns([5, 1])
    log_col.write("**ANALYSIS & EVENT LOG**")
    if clear_col.button("Clear", use_container_width=True):
        st.session_state.log = []
        st.rerun()

    if not st.session_state.log:
        st.caption("No activity yet — click a week to begin.")
    else:
        # Color map for log entry types
        dot_color = {"analysis": "🟢", "rollback": "🔴", "system": "⚪"}

        for entry in st.session_state.log:
            dot  = dot_color.get(entry["type"], "⚪")
            week_label = f"**W{entry['week']}**" if entry.get("week") is not None else ""
            ts   = entry["ts"]
            text = entry["text"]

            col_ts, col_dot, col_text = st.columns([1, 0.2, 6])
            col_ts.caption(ts)
            col_dot.write(dot)
            if week_label:
                col_text.markdown(f"{week_label} — {text}")
            else:
                col_text.markdown(text)