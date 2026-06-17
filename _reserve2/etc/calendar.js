function ShowCalendar() {
	var weekLabels = ["天", "一", "二", "三", "四", "五", "六"];
	var daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
	var queryParams = [];
	var query = window.location.search.substring(1);
	var pairs = query.split("&");
	var i;

	for (i = 0; i < pairs.length; i++) {
		var separatorIndex = pairs[i].indexOf("=");
		if (separatorIndex > 0) {
			var key = pairs[i].substring(0, separatorIndex);
			var value = pairs[i].substring(separatorIndex + 1);
			queryParams[key] = value;
		}
	}

	var schoolCode = 0;
	if (queryParams["School"]) {
		schoolCode = queryParams["School"];
	}

	var today = new Date();
	var currentYear = today.getFullYear();
	var currentMonth = today.getMonth();
	var currentDay = today.getDate();
	var selectedDay;
	var displayMonth;
	var displayYear;

	if (queryParams["ClassDate"] && queryParams["ClassMonth"] && queryParams["ClassYear"]) {
		selectedDay = parseInt(queryParams["ClassDate"], 10);
		displayMonth = parseInt(queryParams["ClassMonth"], 10) - 1;
		displayYear = parseInt(queryParams["ClassYear"], 10);
	} else {
		displayYear = today.getFullYear();
		displayMonth = today.getMonth();
		selectedDay = 32;
	}

	var isCurrentMonth = currentYear === displayYear && currentMonth === displayMonth;
	if (((displayYear % 4) === 0 && (displayYear % 100) !== 0) || (displayYear % 400) === 0) {
		daysInMonth[1] = 29;
	}

	var firstDayOfMonth = new Date(displayYear, displayMonth, 1);
	var firstWeekday = firstDayOfMonth.getDay();
	var nextMonth = displayMonth + 1;
	var nextMonthYear;
	var previousMonth = displayMonth - 1;
	var previousMonthYear;

	if (nextMonth === 12) {
		nextMonth = 0;
		nextMonthYear = displayYear + 1;
	} else {
		nextMonthYear = displayYear;
	}

	if (previousMonth === -1) {
		previousMonth = 11;
		previousMonthYear = displayYear - 1;
	} else {
		previousMonthYear = displayYear;
	}

	var rowCount = Math.ceil((firstWeekday + daysInMonth[displayMonth]) / 7);
	var calendarCells = new Array(7 * rowCount);
	for (i = 0; i < 7 * rowCount; i++) {
		calendarCells[i] = "　";
	}
	for (i = 0; i < daysInMonth[displayMonth]; i++) {
		calendarCells[i + firstWeekday] = i + 1;
	}

	document.write("<table class='jscalendar' cellspacing='0' style='width:100%; max-width:700px; table-layout:fixed;'>");
	document.write("<tr class='cahead' style='height:80px;'>");
	if (isCurrentMonth) {
		document.write("<th>　</th>");
	} else {
		document.write("<th><a title='前月へ' href='Javascript:GoReserve(", previousMonthYear, ",", previousMonth + 1, ",", 32, ",", schoolCode, ");'>&laquo;</a></th>");
	}
	document.write("<th colspan='5' class='camonth'>");
	document.write(displayYear, "年", displayMonth + 1, "月");
	document.write("</th>");
	document.write("<th><a title='翌月へ' href='Javascript:GoReserve(", nextMonthYear, ",", nextMonth + 1, ",", 32, ",", schoolCode, ");'>&raquo;</a></th>");
	document.write("</tr>");

	document.write("<tr style='height:56px;'>");
	for (i = 0; i < 7; i++) {
		document.write("<th class='cadayofweek' style='height:56px;'>");
		document.write(weekLabels[i]);
		document.write("</th>");
	}
	document.write("</tr>");

	for (i = 0; i < rowCount; i++) {
		document.write("<tr style='height:100px;'>");
		for (var j = 0; j < 7; j++) {
			if (j === 0) {
				document.write("<td class='casun' style='height:100px;'>");
			} else {
				document.write("<td style='height:100px;'>");
			}

			var cellDay = calendarCells[j + (i * 7)];
			if (cellDay === selectedDay) {
				document.write("<strong style='display:flex;align-items:center;justify-content:center;height:100px;'>", cellDay, "</strong>");
			} else if (displayMonth === currentMonth && displayYear === currentYear && cellDay < currentDay) {
				document.write(cellDay);
			} else if (cellDay === currentDay && displayYear === currentYear && displayMonth === currentMonth) {
				document.write("<strong class='canow' style='display:flex;align-items:center;justify-content:center;height:100px;'><a style='display:flex;align-items:center;justify-content:center;height:100px;width:100%;' href='Javascript:GoReserve(", displayYear, ",", displayMonth + 1, ",", cellDay, ",", schoolCode, ");'>", cellDay, "</a></strong>");
			} else if (cellDay !== "　") {
				document.write("<a style='display:flex;align-items:center;justify-content:center;height:100px;width:100%;' href='Javascript:GoReserve(", displayYear, ",", displayMonth + 1, ",", cellDay, ",", schoolCode, ");'>", cellDay, "</a>");
			} else {
				document.write(cellDay);
			}
			document.write("</td>");
		}
		document.write("</tr>");
	}
	document.write("</table>");
}

function GoReserve(year, month, date, school) {
	location.search = "ClassYear=" + year + "&ClassMonth=" + month + "&ClassDate=" + date + "&School=" + school;
}