module Nid 
  extend ActiveSupport::Concern 

  included do 
    # Use solr to look up an object with a given content type 
    # by drupal node reference id.
    def self.find_by_nid(nid)
      k = self.name
      qs    = "active_fedora_model_ssi:\"#{k}\" AND drupal_nid_ssim:\"#{nid}\""

      result = ActiveFedora::SolrService.query(qs).first 
      result ? SolrDocument.new(result) : nil
    end
    
    has_attributes :nid, datastream: "properties", multiple: false 
    delegate :nid=, to: "properties"
  end
end