require 'logger'

class AGI
  # Create a new AGI object and parse the Asterisk environment. Usually you
  # will call this without arguments, but you might have your bat-reasons to
  # provide +io_in+ and +io_out+.
  #
  # Also sets up a default SIGHUP trap, logging the event and calling exit. If
  # you want to do some cleanup on SIGHUP instead, override it, e.g.:
  #     trap('SIGHUP') { cleanup }
  def initialize(io_in=STDIN, io_out=STDOUT)
    @io_in = io_in
    @io_out = io_out

    # read vars
    @env = {}
    while (line = @io_in.readline.strip) != ''
      k,v = line.split(':')
      k.strip! if k
      v.strip! if v
      k = $1 if k =~ /^agi_(.*)$/
      @env[k] = v
    end

    @log = Logger.new(STDERR)

    # default trap for SIGHUP, which is what Asterisk sends us when the other
    # end hangs up. An uncaught SIGHUP exception pollutes STDERR needlessly.
    trap('SIGHUP') { @log.debug('Holy SIGHUP, Batman!'); exit }
  end
  
  # Logger object, defaults to <tt>Logger.new(STDERR)</tt>. By default nothing
  # is logged, but if you turn up the log level to +DEBUG+ you'll see the
  # behind-the-scenes communication.
  attr_accessor :log

  # A Hash with the initial environment. Leave off the +agi_+ prefix
  attr_accessor :env
  alias :environment :env

  # Environment access shortcut. Use strings or symbols as keys.
  def [](key)
    @env[key.to_s]
  end

  # Send the given command and arguments. Converts +nil+ and "" in
  # +args+ to literal empty quotes
  def send(cmd, *args)
    args.map! {|a| (a.nil? or a == '') ? '""' : a}
    msg = [cmd, *args].join(' ')
    @log.debug ">> "+msg
    @io_out.puts msg
    @io_out.flush # I'm not sure if this is necessary, but just in case
    resp = @io_in.readline
    @log.debug "<< "+resp
    Response.new(resp)
  end

  # Shortcut for send. e.g. 
  #     a.say_time(Time.now.to_i, nil) 
  # is the same as 
  #     a.send("SAY TIME",Time.now.to_i,'""')
  def method_missing(symbol, *args)
    cmd = symbol.to_s.upcase.tr('_',' ')
    send(cmd, *args)
  end

  # The answer to every AGI#send is one of these.
  class Response
    # Raw response string
    attr_accessor :raw
    # The return code, usually (almost always) 200
    attr_accessor :code
    # The result value
    attr_accessor :result
    # The note in parentheses (if any), stripped of parentheses
    attr_accessor :parenthetical
    alias :note :parenthetical
    # The endpos value (if any)
    attr_accessor :endpos

    # raw:: A string of the form "200 result=0 [(foo)] [endpos=1234]"
    #
    # The variables are populated as you would think. The parenthetical note is
    # stripped of its parentheses.
    #
    # Don't forget that result is often an ASCII value rather than an integer
    # value. In that case you should test against ?d where d is a digit.
    def initialize(raw)
      @raw = raw
      @raw =~ /^(\d+)\s+result=(-?\d+)(?:\s+\((.*)\))?(?:\s+endpos=(-?\d+))?/
      @code = ($1 and $1.to_i)
      @result = ($2 and $2.to_i)
      @parenthetical = $3
      @endpos = ($4 and $4.to_i)
    end
  end
end
