# WorkerPool

A pool module for user-defined workers.

## Example

The following module is a sample worker module, which sends `:ok` and a doubled list of each element to the host process after being called.

```elixir
defmodule SampleWorker do
  use WorkerPool.Worker

  @impl true
  def work({pid, list}), do: send(pid, {:ok, Enum.map(list, & &1 * 2)})
end
```

```elixir
WorkerPool.start_link(SampleWorker)

WorkerPool.get_worker(SampleWorker) |> send({:work, {self(), [1, 2, 3]}})
receive do
  {:ok, result} -> IO.inspect result
  after 1000 -> IO.puts "Timeout"
end
```


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `worker_pool` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:worker_pool, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/worker_pool](https://hexdocs.pm/worker_pool).

