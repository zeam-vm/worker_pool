defmodule WorkerPool do
  @moduledoc """
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

  """

  use GenServer

  @doc """
  Gets the server name of the given worker module.

  ## Parameters

    - `worker_module`: Module of the worker that implements WorkerPool.Worker.

  """
  @spec server_name(module) :: atom
  def server_name(worker_module) do
    :"#{__MODULE__}.#{worker_module}"
  end

  @doc """
  Starts a `WorkerPool` process for the given worker module that linked to the current process.

  ## Parameters

  	- `worker_module`: Module of the worker that implements WorkerPool.Worker.

  """
  @spec start_link(module) :: {:ok, pid}
  def start_link(worker_module) do
    GenServer.start_link(__MODULE__, {worker_module, []}, name: server_name(worker_module))
  end

  @doc """
  Gets a worker of the given module.

  The worker has been instantiated and cached before calling `get_worker`.
  """
  @spec get_worker(module) :: pid
  def get_worker(worker_module) do
    GenServer.call(server_name(worker_module), :get_worker)
  end

  @doc false
  @spec alive(pid, module) :: :ok
  def alive(pid, worker_module) do
    GenServer.cast(server_name(worker_module), {:alive, pid})
  end

  @impl true
  @spec init({module, list}) :: {:ok, {module, list, non_neg_integer}}
  def init({worker_module, pool}) do
    {:ok, {worker_module, pool, 0}}
  end

  @impl true
  @spec handle_call(atom, {pid, any}, {module, list, non_neg_integer}) ::
          {:reply, pid, {module, list, non_neg_integer}}
  def handle_call(:get_worker, _from, {worker_module, [], wid}) do
    {:reply, WorkerPool.Worker.create(worker_module, wid), {worker_module, [], wid + 1}}
  end

  def handle_call(:get_worker, _from, {worker_module, [head | tail], wid}) do
    {:reply, head, {worker_module, tail, wid}}
  end

  @impl true
  @spec handle_cast({atom, pid}, {module, list, non_neg_integer}) ::
          {:noreply, {module, list, non_neg_integer}}
  def handle_cast({:alive, pid}, {worker_module, pool, wid}) do
    {:noreply, {worker_module, pool ++ [pid], wid}}
  end
end
