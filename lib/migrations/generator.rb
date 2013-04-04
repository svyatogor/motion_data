module MotionData
  module Migrations
    class Generator

      def self.build
        begin
          require File.expand_path("db/schema.rb")
        rescue LoadError
          raise "Failed to load schema definition from db/schema.rb"
        end

        builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
          xml.model(database_model_attributes) do
            Schema.instance.entities.each do |entity|
              xml.entity(:name => entity.name.to_s.camelize, :representedClassName => entity.name.to_s.camelize, :syncable => "YES") do

                entity.properties.each do |property|
                  xml.attribute(property.attributes)
                end

                entity.relationships.each do |relationship|
                  xml.relationship(relationship.attributes)
                end

              end
            end
          end
        end
        builder.to_xml
      end

      def self.database_model_attributes
        {
            :name                              => "",
            :userDefinedModelVersionIdentifier => "",
            :type                              => "com.apple.IDECoreDataModeler.DataModel",
            :documentVersion                   => "1.0",
            :lastSavedToolsVersion             => "1811",
            :systemVersion                     => "11D50",
            :minimumToolsVersion               => "Automatic",
            :macOSVersion                      => "Automatic",
            :iOSVersion                        => "Automatic"
        }
      end
    end
  end
end
