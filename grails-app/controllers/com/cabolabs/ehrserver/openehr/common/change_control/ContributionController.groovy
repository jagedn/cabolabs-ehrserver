package com.cabolabs.ehrserver.openehr.common.change_control

import org.springframework.dao.DataIntegrityViolationException
import grails.plugin.springsecurity.SpringSecurityUtils
import com.cabolabs.security.Organization
import com.cabolabs.ehrserver.openehr.common.change_control.Contribution

class ContributionController {

   def springSecurityService
   
   static allowedMethods = [save: "POST", update: "POST", delete: "POST"]

   def index()
   {
      redirect(action: "list", params: params)
   }

   def list(int max, int offset, String sort, String order, String ehdUid)
   {
      max = Math.min(max ?: 10, 100)
      if (!offset) offset = 0
      if (!sort) sort = 'id'
      if (!order) order = 'desc'
     
      def list, org
      def c = Contribution.createCriteria()
      
      if (SpringSecurityUtils.ifAllGranted("ROLE_ADMIN"))
      {
         /*
         list = Contribution.list(params)
         cnt = Contribution.count()
         */
         list = c.list (max: max, offset: offset, sort: sort, order: order) {
            if (ehdUid)
            {
               ehr {
                  like('uid', '%'+ehdUid+'%')
               }
            }
         }
      }
      else
      {
         // auth token used to login
         def auth = springSecurityService.authentication
         org = Organization.findByNumber(auth.organization)
         
         //list = Contribution.findAllByOrganizationUid(org.uid, params)
         //cnt = Contribution.countByOrganizationUid(org.uid)
         
         list = c.list (max: max, offset: offset, sort: sort, order: order) {
            eq ('organizationUid', org.uid)
            if (ehdUid)
            {
               ehr {
                  like('uid', '%'+ehdUid+'%')
               }
            }
         }
      }
     
      // =========================================================================
      // For charting
      
      // Show 1 year by month
      def now = new Date()
      def oneyearbehind = now - 365
      
      def data = Contribution.withCriteria {
          projections {
              count('id')
              groupProperty('yearMonthGroup') // count contributions in the same month
          }
          if (!SpringSecurityUtils.ifAllGranted("ROLE_ADMIN"))
          {
             eq('organizationUid', org.uid)
          }
          audit {
             between('timeCommitted', oneyearbehind, now)
          }
      }
      
      //println data
      // =========================================================================

      return [contributionInstanceList: list, total: list.totalCount,
              data: data, start: oneyearbehind, end: now]
   }

   def show(Long id)
   {
      def contributionInstance = Contribution.get(id)
      if (!contributionInstance) {
         flash.message = message(code: 'default.not.found.message', args: [message(code: 'contribution.label', default: 'Contribution'), id])
         redirect(action: "list")
         return
      }

      [contributionInstance: contributionInstance]
   }
}
