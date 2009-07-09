module Gattica
  
  # Encapsulates the data returned by the GA API
  
  class DataSet
    
    include Convertible
    
    attr_reader :total_results, :start_index, :items_per_page, :start_date, :end_date, :points, :xml, :updated
      
    def initialize(xml)
      @xml = xml.to_s
      @total_results = xml.at('openSearch:totalResults').inner_html.to_i
      @start_index = xml.at('openSearch:startIndex').inner_html.to_i
      @items_per_page = xml.at('openSearch:itemsPerPage').inner_html.to_i
      @start_date = Date.parse(xml.at('dxp:startDate').inner_html)
      @end_date = Date.parse(xml.at('dxp:endDate').inner_html)
      @updated = DateTime.parse(xml.at('updated').inner_html)
      @points = xml.search(:entry).collect { |entry| DataPoint.new(entry) }
    end
    
    
    # output important data to CSV, ignoring all the specific data about this dataset 
    # (total_results, start_date) and just output the data from the points
    
    def to_csv(format = :long)
      # build the headers
      output = ''
      columns = []

      # only show the nitty gritty details of id, updated_at and title if requested
      case format
      when :long
        ["id", "updated", "title"].each { |c| columns << c }
      end
      
      unless @points.empty?   # if there was at least one result
        @points.first.dimensions.map {|d| d.key}.each { |c| columns << c }
        @points.first.metrics.map {|m| m.key}.each { |c| columns << c }
      end
      
      output = CSV.generate_line(columns) + "\n"

      # get the data from each point
      @points.each do |point|
        output += point.to_csv(format) + "\n"
      end
      
      return output
    end
    
    
    def to_yaml
      { 'total_results' => @total_results,
        'start_index' => @start_index,
        'items_per_page' => @items_per_page,
        'start_date' => @start_date,
        'end_date' => @end_date,
        'points' => @points}.to_yaml
    end
    
  end
  
end