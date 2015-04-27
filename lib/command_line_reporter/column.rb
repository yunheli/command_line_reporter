require 'colored'
require 'unicode/display_width'
module CommandLineReporter
  class Column
    include OptionsValidator

    VALID_OPTIONS = [:width, :padding, :align, :color, :bold, :underline, :reversed]
    attr_accessor :text, :size, *VALID_OPTIONS

    def initialize(text = nil, options = {})
      self.validate_options(options, *VALID_OPTIONS)

      self.text = text.to_s

      self.width = options[:width]  || 10
      self.align = options[:align] || 'left'
      self.padding = options[:padding] || 0
      self.color = options[:color] || nil
      self.bold = options[:bold] || false
      self.underline = options[:underline] || false
      self.reversed = options[:reversed] || false

      raise ArgumentError unless self.width > 0
      raise ArgumentError unless self.padding.to_s.match(/^\d+$/)
    end

    def size
      self.width - 2 * self.padding
    end

    def required_width
      self.text.to_s.size + 2 * self.padding
    end

    def screen_rows
      if self.text.nil? || self.text.empty?
        [' ' * self.width]
      else
        #todo
        #self.text.scan(/.{1,#{self.size}}/m).map {|s| to_cell(s)}
        split_text(self.text).map {|s| to_cell(s)}
      end
    end

    def split_text  text
      i = 0
      s = ""
      arr = []
      text.scan(/./).each do |x|
        if i > self.size
          i = 0
          arr.push(s)
          s = ""
        end
        s += x
        i += x.display_width
      end
      if s.length > 0
        arr.push(s)
      end
      arr
    end

    private

    def to_cell(str)
      # NOTE: For making underline and reversed work Change so that based on the
      # unformatted text it determines how much spacing to add left and right
      # then colorize the cell text
      cell =  str.empty? ? blank_cell : aligned_cell(str)
      padding_str = ' ' * self.padding
      padding_str + colorize(cell) + padding_str
    end

    def blank_cell
      ' ' * self.size
    end

    def aligned_cell(str)
      case self.align
      when 'left'
        str.ljust(self.size - (str.display_width - str.length))
      when 'right'
        str.rjust(self.size - (str.display_width - str.length))
      when 'center'
        str.ljust((self.size- (str.display_width - str.length) - str.size)/2.0 + str.size).rjust(self.size - (str.display_width - str.length))
      end
    end

    def colorize(str)
      str = str.send(color) if self.color
      str = str.send('bold') if self.bold
      str
    end
  end
end
