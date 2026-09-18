import Quickshell
import QtQuick

// Ports waybar's clock module, including the {calendar} month grid its tooltip
// rendered. Qt has no calendar-as-text helper, so the grid is built here. waybar
// wrapped it in <tt> to get a monospace column; the bar font already is one, so
// the columns align without a tag StyledText may not support.
BarButton {
  id: root

  // Minutes, not the default Seconds: the format stops at minutes, so a per-second
  // tick would wake the process 60x more often for no visible change.
  SystemClock {
    id: clock

    precision: SystemClock.Minutes
  }

  bold: true
  text: Qt.formatDateTime(clock.date, "dddd, MMMM dd, yyyy  hh:mm AP")

  tooltip: "<big>" + Qt.formatDateTime(clock.date, "yyyy MMMM") + "</big><br>"
    + root.monthGrid(clock.date) + "<br>"
    + "Click: open calendar"

  function monthGrid(date) {
    const year = date.getFullYear();
    const month = date.getMonth();
    const today = date.getDate();

    // Day 0 of the next month is the last day of this one.
    const leadingBlanks = new Date(year, month, 1).getDay();
    const dayCount = new Date(year, month + 1, 0).getDate();

    const cells = [];
    for (let blank = 0; blank < leadingBlanks; blank++)
      cells.push("  ");

    for (let day = 1; day <= dayCount; day++) {
      const label = day < 10 ? " " + day : String(day);
      cells.push(day === today ? "<b>" + label + "</b>" : label);
    }

    const rows = ["Su Mo Tu We Th Fr Sa"];
    for (let start = 0; start < cells.length; start += 7)
      rows.push(cells.slice(start, start + 7).join(" "));

    return rows.join("<br>");
  }
}
