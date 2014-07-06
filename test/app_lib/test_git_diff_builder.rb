  test 'chunk with a space in its filename' do
    @diff_lines =
    @source_lines =
    @expected =
    assert_equal_builder
    @diff_lines =
    @source_lines =
    @expected =
    assert_equal_builder
    @diff_lines =
    @source_lines =
    @expected =
    assert_equal_builder
  test 'diffs 7 lines apart are not merged ' +
       'into contiguous sections in one chunk' do
    @diff_lines =
    @source_lines =
    @expected =
    assert_equal_builder
    @diff_lines =
    @source_lines =
    @expected =
    assert_equal_builder
    @diff_lines =
    @source_lines =
    @expected =
    assert_equal_builder
    @diff_lines =
    @source_lines =
    @expected =
    assert_equal_builder
    @diff_lines =
    @source_lines =
    @expected =
    assert_equal_builder
    @diff_lines =
    @source_lines =
    @expected =
    assert_equal_builder
    @diff_lines =
    @source_lines =
    @expected =
    assert_equal_builder
  def assert_equal_builder
    diff = GitDiff::GitDiffParser.new(@diff_lines).parse_one
    builder = GitDiff::GitDiffBuilder.new()
    actual = builder.build(diff, @source_lines.split("\n"))
    assert_equal @expected, actual
  end
