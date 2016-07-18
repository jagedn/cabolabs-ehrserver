<%@ page import="com.cabolabs.ehrserver.openehr.common.change_control.Contribution" %>
<!doctype html>
<html>
  <head>
    <meta name="layout" content="admin">
    <g:set var="entityName" value="${message(code: 'contribution.label', default: 'Contribution')}" />
    <title><g:message code="default.list.label" args="[entityName]" /></title>
    <asset:javascript src="highcharts/highcharts.js" />
    <script type="text/javascript">

      var series = [];
      var serie = { name: 'contributions', data: [] };
    
	   <%
      println 'var start = Date.UTC('+ (start.year + 1900) +','+ (start.month - 1) +','+ start.date +');'
      def match
	   data.each { point ->
	       
         match = (point[1].toString() =~ /(\d{4})(\d{2})/) //=match for year and month, /(\d{4})(\d{2})(\d{2})/ match for ymd

         // -1 because month is 0 based
	      println 'serie.data.push(['+
          'Date.UTC('+ match[0][1] +', (' + match[0][2] +' -1), 1), '+ point[0] +
         ']);' // point[0] is the count, point[1] is the group date
	   }
	   %>

      // avoid error on empty serie.data
      if (serie.data.length > 0) series.push(serie);

	   console.log(series);
    
	   $(function () {
	      var chart = new Highcharts.Chart({
           chart: {
              renderTo: 'contributionsChartContainer',
              type: 'column',
              zoomType: 'x'
           },
           title: {
               text: 'Contributions'
           },
           subtitle: {
               text: ''
           },
           xAxis: {
               type: 'datetime',
               dateTimeLabelFormats: {
                   second: '%H:%M:%S',
                   minute: '%H:%M',
                   hour: '%H:%M',
                   day: '%e. %b',
                   week: '%e. %b',
                   month: '%b \'%y',
                   year: '%Y'
               },
               tickInterval: 24 * 3600 * 1000 * 30 //= 1 month // 24 * 3600 * 1000 //= 1 day
           },
           yAxis: {
               min: 0,
               allowDecimals: false, // no decimals on y, just integers
               title: {
                   text: 'Count'
               }
           },
           tooltip: {
               headerFormat: '<span style="font-size:10px">{point.key}</span><table>',
               pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' +
                   '<td style="padding:0"><b>{point.y}</b></td></tr>',
               footerFormat: '</table>',
               shared: true,
               useHTML: true,
               xDateFormat: '%b \'%y' //'%Y-%m-%d'
           },
           plotOptions: {
               column: {
                   pointPadding: 0,
                   borderWidth: 0,
                   groupPadding: 0.1,
                   //pointStart: start
               }
           },
           series: series
	     });
	   });
    </script>
    <style>
     /* adjusts the filder input width */
     @media (min-width: 768px) {
      #ipt_ehr {
       width: 320px;
      }
     }
    </style>
  </head>
  <body>
    <div class="row">
      <div class="col-lg-12">
        <h1><g:message code="contribution.list.title" /></h1>
      </div>
    </div>
    <div class="row row-grid">
      <div class="col-lg-12">
        <g:form class="form-inline" action="list">
          <input type="hidden" name="sort" value="${params.sort}" />
          <input type="hidden" name="order" value="${params.order}" />
          <div class="form-group">
            <label for="ipt_ehr">EHR</label>
            <input type="text" class="form-control" name="ehdUid" id="ipt_ehr" placeholder="11111111-1111-1111-1111-111111111111" value="${params?.ehdUid}" />
          </div>
          <button type="submit" class="btn btn-default">Filter</button>
        </g:form>
      </div>
    </div>
    
    <div class="row row-grid">
      <div class="col-lg-12">
        <div id="contributionsChartContainer"></div>
      </div>
    </div>
    
    <div class="row row-grid">
      <div class="col-lg-12">
         <g:if test="${flash.message}">
	        <div class="message" role="status">${flash.message}</div>
	      </g:if>
	      <div class="table-responsive">
           <table class="table table-striped table-bordered table-hover">
		        <thead>
		          <tr>
		            <g:sortableColumn property="uid" title="${message(code: 'contribution.uid.label', default: 'UID')}" params="${params}" />
		            <th>EHR</th>
		            <%-- uses the id because is easier than sorting by timeCommitted and have the same order --%>
		            <g:sortableColumn property="id" title="${message(code: 'contribution.timeCommitted.label', default: 'Time Committed')}" params="${params}" />
		            <th># Versions</th>
		          </tr>
		        </thead>
		        <tbody>
			        <g:each in="${contributionInstanceList}" status="i" var="contributionInstance">
			          <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
			            <td><g:link action="show" id="${contributionInstance.id}">${fieldValue(bean: contributionInstance, field: "uid")}</g:link></td>
			            <td>${contributionInstance.ehr.uid}</td>
			            <td>${contributionInstance.audit.timeCommitted}</td>
			            <td>${contributionInstance.versions.size()}</td>
			          </tr>
			        </g:each>
		        </tbody>
		     </table>
	      </div>
         <g:paginator total="${total}" />
      </div>
    </div>
  </body>
</html>
