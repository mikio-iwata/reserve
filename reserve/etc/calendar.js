function ShowCalendar(){
	myWeekTbl = new Array("天","一","二","三","四","五","六");
	//  EnglishMonth = new Array("1月","2月","March","April","May","6月","July","August","September","October","November","December");
	myMonthTbl= new Array(31,28,31,30,31,30,31,31,30,31,30,31);

	var qsParm = new Array(); //GET取得開始
		var query = window.location.search.substring(1); 
		var parms = query.split('&'); 
		for (var i=0; i<parms.length; i++) { 
			var pos = parms[i].indexOf('='); 
			if (pos > 0) { 
			var key = parms[i].substring(0,pos); 
			var val = parms[i].substring(pos+1); 
			qsParm[key] = val; 
			} 
		} //GET取得修了
		
	mySchool = 0; //仮の番号
	if(qsParm["School"]){
			mySchool = qsParm["School"];
	}

	myDate = new Date();
	nowYear = myDate.getFullYear();
	nowMonth = myDate.getMonth();
	nowDay = myDate.getDate();
	
	if(qsParm["ClassDate"] && qsParm["ClassMonth"] && qsParm["ClassYear"]){
		myToday = eval(qsParm["ClassDate"]);
		myMonth = eval(qsParm["ClassMonth"]) - 1;
		myYear = eval(qsParm["ClassYear"]);
	}else{
		myYear = myDate.getYear();
		myYear = (myYear<2000) ? (1900+myYear) : (myYear);
		myMonth = myDate.getMonth();
		//myToday = myDate.getDate();
		myToday = 32;
	}
	thisMonth = false;
	if(nowYear == myYear && nowMonth == myMonth){
		thisMonth = true;
	}
	
  if (((myYear%4)==0 && (myYear%100)!=0) || (myYear%400)==0){//閏年の判定
    myMonthTbl[1] = 29;
  }
  
  myMonth1 = new Date(myYear, myMonth, 1); //月頭を取得
  myWeek = myMonth1.getDay(); //ついたちの曜日を取得
  
  //前月、翌月の取得
  nextMonth = myMonth + 1;
  if(nextMonth == 12){
  	  nextMonth = 0;
  	  nextMonthsYear = myYear + 1;
  }else{
  	nextMonthsYear = myYear;
  }
  previousMonth = myMonth - 1;
  if(previousMonth == -1){
  	  previousMonth = 11;
  	  previousMonthsYear = myYear - 1;
  }else{
  	  previousMonthsYear = myYear ;
  }
  
  //カレンダー描画
  myTblLine = Math.ceil((myWeek+myMonthTbl[myMonth])/7);
  myTable   = new Array(7*myTblLine);
  for(i=0; i<7*myTblLine; i++){
    myTable[i]="　";
  }
  for(i=0; i<myMonthTbl[myMonth]; i++){
    myTable[i+myWeek]=i+1;
  }
  
  document.write("<table class='jscalendar' cellspacing='0'>");
  document.write("<tr class='cahead'>");
  if(thisMonth){
  	  document.write("<th>　</th>");
  }else{
  	document.write("<th><a title='前月へ' href='Javascript:GoReserve(",previousMonthsYear,",",previousMonth+1,",",32,",",mySchool,");'>&laquo;</a></th>");
  }
  document.write("<th colspan='5' class='camonth'>");
  document.write(myYear,"年",myMonth+1,"月");
  document.write("</th>");
  document.write("<th><a title='翌月へ' href='Javascript:GoReserve(",nextMonthsYear,",",nextMonth+1,",",32,",",mySchool,");'>&raquo;</a></th>");
  
  document.write("</tr>");
  
  document.write("<tr>");
  for(i=0; i<7; i++){
    document.write("<th class='cadayofweek'>");
    document.write(myWeekTbl[i]);
    document.write("</th>");
  }
  document.write("</tr>");
  for(i=0; i<myTblLine; i++){
    document.write("<tr>");
    for(j=0; j<7; j++){
      if(j == 0){
      document.write("<td class='casun'>");
      }else{
      document.write("<td>");
    }
      myDat = myTable[j+(i*7)];
      if (myDat==myToday){
        document.write("<strong>",myDat,"</strong>");
      }else if(myMonth == nowMonth && myYear == nowYear && myDat < nowDay){
      	document.write(myDat);
      }else if(myDat == nowDay && myYear == nowYear && myMonth == nowMonth){
      	document.write("<strong class='canow'><a href='Javascript:GoReserve(",myYear,",",myMonth+1,",",myDat,",",mySchool,");'>",myDat,"</a></strong>");
      }else if(myDat != "　"){
       document.write("<a href='Javascript:GoReserve(",myYear,",",myMonth+1,",",myDat,",",mySchool,");'>",myDat,"</a>");
      }else{
      	  document.write(myDat);
      }
      document.write("</td>");
    }
    document.write("</tr>");
  }
	document.write("</table>");
}
function GoReserve(year,month,date,school){
//	location.href = ;
	location.search = 'ClassYear=' + year + '&ClassMonth=' + month + '&ClassDate=' + date + '&School=' + school;
}
