require 'rubygems'
require 'bundler/setup'
require 'differ'

class Diff
  SEPARATOR = $/
  
  module CustomFormat
    class << self
      def format(change)
        (change.change? && as_change(change)) ||
        (change.delete? && as_delete(change)) ||
        (change.insert? && as_insert(change)) ||
        ''
      end

      private
      
      def as_insert(change)
        {added: change.insert.split(SEPARATOR)}
      end

      def as_delete(change)
        {deleted: change.delete.split(SEPARATOR)}
      end

      def as_change(change)
        {changed: {from: change.delete.split(SEPARATOR), to: change.insert.split(SEPARATOR)}}
      end
    end
  end
  
  # TODO handle mutiply files to reverse merge changes
  # TODO Logger
  # TODO catch IO exceptions
  def initialize(file_names)
    @str1, @str2 = IO.read(file_names[0]), IO.read(file_names[1])
    @line = 1
    Differ.format = CustomFormat
  end
  
  def compare
    changes = Differ.diff(@str2, @str1, SEPARATOR).instance_variable_get('@raw').map(&:to_s)
    line = 1
    p "LOG: #{changes}"
    
    changes.each do |hash_or_str|
      case hash_or_str.class.name
      when 'Hash'
        log_hash(hash_or_str)
      when 'String'
        #TODO patch Diff to split unchanged lines
        hash_or_str.split(SEPARATOR).reject{|txt| txt == '' }.each do |txt|
          p "#{@line} #{txt}"
          @line += 1
        end
      end
    end
  end
  
  private
  
  def log_hash(hash)
    if hash[:changed]
      until hash[:changed][:from].empty? && hash[:changed][:to].empty?
        if hash[:changed][:to].empty? # means replaced lines size gt target lines size
          p "#{@line} - #{hash[:changed][:from].shift}"
        else
          p "#{@line} * #{hash[:changed][:from].shift} | #{hash[:changed][:to].shift}"
        end
        
        @line += 1
      end
    elsif hash[:added]
      # TODO patch Diff, avoid activesupport
      hash[:added].reject{|txt| txt == '' }.each do |txt|
        p "#{@line} + #{txt}"
        @line += 1
      end
    end
  end
end

if ARGV.size < 2 or ARGV.size > 2
  $stderr.puts "usage: bundle exec #{File.basename($0)} file1.txt file2.txt"
  exit 127
end

Diff.new(ARGV).compare