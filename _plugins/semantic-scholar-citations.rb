require "active_support/all"
require "net/http"
require "json"
require "uri"

module Helpers
  extend ActiveSupport::NumberHelper
end

module Jekyll
  class SemanticScholarCitationsTag < Liquid::Tag
    Citations = {}

    def initialize(tag_name, params, tokens)
      super
      @doi_var = params.strip
    end

    def render(context)
      doi = context[@doi_var]
      return "N/A" if doi.nil? || doi.to_s.strip.empty?

      # Strip a leading https://doi.org/ if present, the API wants the bare DOI
      clean_doi = doi.to_s.sub(%r{\Ahttps?://doi\.org/}, "")

      return SemanticScholarCitationsTag::Citations[clean_doi] if SemanticScholarCitationsTag::Citations[clean_doi]

      citation_count = "N/A"

      begin
        uri = URI("https://api.semanticscholar.org/graph/v1/paper/DOI:#{clean_doi}?fields=citationCount")
        req = Net::HTTP::Get.new(uri)
        req["User-Agent"] = "pcsearle.github.io Jekyll build (mailto:pcs222@cornell.edu)"

        res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 10) do |http|
          http.request(req)
        end

        if res.is_a?(Net::HTTPSuccess)
          data = JSON.parse(res.body)
          if data["citationCount"]
            citation_count = Helpers.number_to_human(
              data["citationCount"],
              format: "%n%u",
              precision: 2,
              units: { thousand: "K", million: "M", billion: "B" }
            )
          end
        else
          puts "Semantic Scholar API returned #{res.code} for DOI #{clean_doi}"
        end

        # Be polite to the (unauthenticated, rate-limited) API
        sleep(1)
      rescue Exception => e
        puts "Error fetching Semantic Scholar citation count for #{clean_doi}: #{e.class} - #{e.message}"
      end

      SemanticScholarCitationsTag::Citations[clean_doi] = citation_count
      citation_count
    end
  end
end

Liquid::Template.register_tag("semantic_scholar_citations", Jekyll::SemanticScholarCitationsTag)
