defmodule DebpressTest.Util do
	use ExUnit.Case

	test "make_temp_path returns a string" do
		assert is_binary(Debpress.Util.make_temp_path("prefix", "jpg"))
	end

	test "temporary path starts with System.tmp_dir/prefix" do
		prefix = "prefix"
		path = Debpress.Util.make_temp_path(prefix, "jpg")
		assert String.starts_with?(path, Path.join(System.tmp_dir, prefix))
	end

	test "if extension provided, temporary path ends with '.extension'" do
		extension = "jpg"
		path = Debpress.Util.make_temp_path("prefix", extension)
		assert String.ends_with?(path, ".#{extension}")
		assert not String.ends_with?(path, "..#{extension}")
	end

	test "if extension empty, temporary path does not end with '.'" do
		extension = ""
		path = Debpress.Util.make_temp_path("prefix", extension)
		assert not String.ends_with?(path, ".")
	end
end
