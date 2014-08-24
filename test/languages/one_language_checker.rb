
require_relative '../all'

class OneLanguageChecker

  def initialize(root_path, verbose)
    ENV['CYBERDOJO_TEST_ROOT_DIR'] = 'true'
    @root_path = File.absolute_path(root_path) + '/'
    @verbose = verbose
  end

  def check(language_name)
    # if running on a Docker server
    #    return [red,amber,green] state
    # else
    #    return nil
    @language = dojo.languages[language_name]
    if @language.runnable?
      vputs "  #{language_name} " + ('.' * (35-language_name.to_s.length))
      t1 = Time.now
      rag = red_amber_green
      t2 = Time.now
      took = ((t2 - t1) / 3).round(2)
      vputs " (~ #{took} seconds)\n"
      rag
    end
  end

private

  def red_amber_green
    # NB: This works by creating a new kata for each
    #     red/amber/green test. This is needlessly slow.
    #     Just make one kata, and then verify
    #     o) its starts tests red
    #     o) s/6*9/6*7/ tests green
    #     o) s/6*9/s345 * 9345/ tests amber
    [
      language_test(:red),
      language_test(:amber),
      language_test(:green),
    ]
  end

  def language_test(colour)
    pattern = pattern_6times9
    filename = filename_6times9(pattern[:red])
    from = pattern[:red]
    to = pattern[colour]
    exercise = dojo.exercises['Fizz_Buzz']
    kata = dojo.katas.create_kata(@language, exercise)
    avatar = kata.start_avatar
    visible_files = @language.visible_files
    test_code = visible_files[filename]
    visible_files[filename] = test_code.sub(from, to)

    vputs [
      "<test_code id='#{kata.id}' avatar='#{avatar.name}' expected_colour='#{colour}'>",
      visible_files[filename],
      "</test_code>"
    ].join("\n")

    delta = {
      :changed => [filename],
      :unchanged => visible_files.keys - [filename],
      :deleted => [ ],
      :new => [ ]
    }

    traffic_lights,_,_ = avatar.test(delta, visible_files)

    vputs [
      "<output>",
      visible_files['output'],
      "</output>"
    ].join("\n")

    rag = traffic_lights.last['colour']

    vputs [
      "<test_code actual_colour='#{rag}'>",
      "</test_code>"
    ].join("\n")

    print '.'
    rag
  end

  def pattern_6times9
    case (@language.name)
      when 'Clojure-.test'
        then make_pattern('* 6 9')
      when 'Java-1.8_Cucumber'
        then make_pattern('6 times 9')
      when 'Java-1.8_Mockito',
           'Java-1.8_Powermockito'
        then make_pattern('thenReturn(9)')
      else
        make_pattern('6 * 9')
    end
  end

  def make_pattern(base)
    { :red => base,
      :amber => base.sub('9', '9typo'),
      :green => base.sub('9', '7')
    }
  end

  def filename_6times9(pattern)
    filenames = @language.visible_filenames.select { |visible_filename|
      IO.read(@language.path + visible_filename).include? pattern
    }
    if filenames == [ ]
      message = alert + " no '#{pattern}' file found"
      vputs message
      return ""
    end
    if filenames.length > 1
      message = alert + " multiple '#{pattern}' files " + filenames.inspect
      vputs message
      return ""
    end
    vputs "."
    filenames[0]
  end

  def alert
    "\n>>>#{@language.name}<<\n"
  end

  def vputs(message)
    puts message if @verbose
  end

  def externals
    {
      :disk => OsDisk.new,
      :git => Git.new,
      :runner => runner
    }
  end

  def runner
    if Docker.installed?
      DockerTestRunner.new
    else
      DummyTestRunner.new
    end
  end

  def dojo
    Dojo.new(@root_path,externals)
  end

end