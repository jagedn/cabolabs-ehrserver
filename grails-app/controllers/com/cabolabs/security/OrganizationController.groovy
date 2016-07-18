package com.cabolabs.security


import static org.springframework.http.HttpStatus.*
import grails.transaction.Transactional

//http://grails-plugins.github.io/grails-spring-security-core/guide/single.html#springSecurityUtils
import grails.plugin.springsecurity.SpringSecurityUtils


@Transactional(readOnly = true)
class OrganizationController {

   def springSecurityService
   
   static allowedMethods = [save: "POST", update: "PUT", delete: "DELETE"]

   def index(Integer max)
   {
      params.max = Math.min(max ?: 10, 100)
      
      def list, count
      
      if (SpringSecurityUtils.ifAllGranted("ROLE_ADMIN"))
      {
         list = Organization.list(params)
         count = Organization.count()
      }
      else
      {
         def user = springSecurityService.loadCurrentUser()
         
         //println "organizations: "+ user.organizations.toString()
         
         // no pagination
         list = user.organizations
         count = list.size()
      }
      
      render view:'index', model:[organizationInstanceList:list, total:count]
   }

   // organizationInstance comes from the security filter on params
   def show()
   {
      [organizationInstance: params.organizationInstance]
   }

   def create()
   {
      respond new Organization(params)
   }

   @Transactional
   def save(Organization organizationInstance)
   {
      if (organizationInstance == null)
      {
         notFound()
         return
      }
      log.info "antes de has errors"
      if (organizationInstance.hasErrors())
      {
         log.info "has errors"
         render view:'create', model:[organizationInstance:organizationInstance]
         return
      }

      log.info "luego de has errors"
      organizationInstance.save flush:true
      
      // Assign org to logged user
      def user = springSecurityService.loadCurrentUser()
      user.addToOrganizations(organizationInstance)
      user.save(flush:true)

      
      flash.message = message(code: 'default.created.message', args: [message(code: 'organization.label', default: 'Organization'), organizationInstance.id])
      redirect action:'show', id:organizationInstance.id
   }

   def edit()
   {
      [organizationInstance: params.organizationInstance]
   }

   @Transactional
   def update(String uid, Long version)
   {
      println "update "+ params +" uid: "+ uid
      
      def organizationInstance = Organization.findByUid(uid)
      organizationInstance.properties = params
      organizationInstance.validate()
      
      if (organizationInstance.hasErrors())
      {
         respond organizationInstance.errors, view:'edit'
         return
      }
      
      // TODO check version (see PersonController.update)

      organizationInstance.save flush:true

      redirect action:'show', params:[uid:uid]
   }

   @Transactional
   def delete(Organization organizationInstance)
   {

      if (organizationInstance == null)
      {
         notFound()
         return
      }

      organizationInstance.delete flush:true

      request.withFormat {
         form multipartForm {
            flash.message = message(code: 'default.deleted.message', args: [message(code: 'Organization.label', default: 'Organization'), organizationInstance.id])
            redirect action:"index", method:"GET"
         }
         '*'{ render status: NO_CONTENT }
      }
   }

   protected void notFound()
   {
      request.withFormat {
         form multipartForm {
            flash.message = message(code: 'default.not.found.message', args: [message(code: 'organization.label', default: 'Organization'), params.id])
            redirect action: "index", method: "GET"
         }
         '*'{ render status: NOT_FOUND }
      }
   }
}
