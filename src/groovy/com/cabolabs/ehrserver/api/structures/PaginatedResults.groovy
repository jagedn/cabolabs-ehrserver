package com.cabolabs.ehrserver.api.structures

class PaginatedResults {
   
   // To be used by the marshallers
   String listName
   
   // List of results, can be Ehr, Contribution, etc.
   // Marshallers for those types should be already defined!
   List list
   
   // Pagination information
   int max
   int offset
   int nextOffset
   int prevOffset

   /**
    * calculates nextOffset and prevOffset
    * @return
    */
   def update()
   {
      if (this.max == null || this.offset == null)
         throw new Exception("max or offset are not set yet")
         
      this.nextOffset = this.offset + this.max
      this.prevOffset = ((this.offset - this.max < 0) ? 0 : this.offset - this.max)
   }
}
