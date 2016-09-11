defmodule Debpress.Util do
	@doc """
	Unlinks `path` if it exists.  Must be a file or an empty directory.
	The parent directories must exist in any case.
	"""
	@spec rm_f!(String.t) :: nil
	def rm_f!(path) do
		case File.rm(path) do
			:ok -> nil
			{:error, :enoent} -> nil
			{:error, reason} ->
				raise File.Error, reason: reason, action: "rm", path: path
		end
	end

	@doc ~S"""
	For use in a pipeline like so:

		s
		|> append_if(c.section, "Section: #{c.section}\n")
		|> append_if(true, "Description: #{c.short_description}\n")
		|> append_if(c.long_description, prefix_every_line(c.long_description, " ") <> "\n")

	`expression` is not evaluated unless evaluation of `clause` is truthy.  This avoids
	blowing up on nils and other unexpected values.
	"""
	defmacro append_if(acc, clause, expression) do
		quote do
			if unquote(clause) do
				unquote(acc) <> unquote(expression)
			else
				unquote(acc)
			end
		end
	end

	@spec make_temp_path(String.t, String.t) :: String.t
	def make_temp_path(prefix, extension) do
		random = :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
		Path.join(System.tmp_dir, "#{prefix}-#{random}")
		|> append_if(String.first(extension), ".#{extension}")
	end
end
