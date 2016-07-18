<%@ page import="com.cabolabs.ehrserver.openehr.ehr.Ehr" %>
<!doctype html>
<html>
  <head>
    <meta name="layout" content="admin">
    <g:set var="entityName" value="${message(code: 'ehr.label', default: 'Ehr')}" />
    <title><g:message code="ehr.list.title" /></title>
    <style>
     /* adjusts the filder input width */
     @media (min-width: 768px) {
      #ipt_uid {
       width: 320px;
      }
     }
    </style>
  </head>
  <body>
    <div class="row">
      <div class="col-lg-12">
        <h1><g:message code="ehr.list.title" /></h1>
      </div>
    </div>
    <div class="row row-grid">
      <div class="col-lg-12">
        <g:form class="form-inline" action="list">
          <input type="hidden" name="sort" value="${params.sort}" />
          <input type="hidden" name="order" value="${params.order}" />
          <div class="form-group">
            <label for="ipt_uid">UID</label>
            <input type="text" class="form-control" name="uid" id="ipt_uid" placeholder="11111111-1111-1111-1111-111111111111" value="${params?.uid}" />
          </div>
          <button type="submit" class="btn btn-default">Filter</button>
        </g:form>
      </div>
    </div>
    <div class="row row-grid">
      <div class="col-lg-12">
        <g:if test="${flash.message}">
          <div class="message alert alert-warning" role="status">${flash.message}</div>
        </g:if>
        <div class="table-responsive">
          <table class="table table-striped table-bordered table-hover">
            <thead>
              <tr>
                <g:sortableColumn property="uid" title="${message(code: 'ehr.uid.label', default: 'UID')}" params="${params}" />
                <g:sortableColumn property="dateCreated" title="${message(code: 'ehr.dateCreated.label', default: 'Date Created')}" params="[uid: params.uid]" />
                <th><g:message code="ehr.subject.label" default="Subject" /></th>
              </tr>
            </thead>
            <tbody>
              <g:each in="${list}" status="i" var="ehrInstance">
                <tr class="${(i % 2) == 0 ? 'even' : 'odd'}">
                  <td><g:link action="showEhr" params="[patientUID:ehrInstance.subject.value]">${fieldValue(bean: ehrInstance, field: "uid")}</g:link></td>
                  <td>${fieldValue(bean: ehrInstance, field: "dateCreated")}</td>
                  <td><g:link controller="person" action="show" params="[uid:ehrInstance.subject.value]">${ehrInstance.subject.value}</g:link></td>
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
