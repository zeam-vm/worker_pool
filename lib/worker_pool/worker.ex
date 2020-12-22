defmodule WorkerPool.Worker do
  @moduledoc """
  Documentation for `WorkerPool.Worker`.
  """

  @doc """
  Documentation for `work`
  """
  @callback work(arg :: term) ::
              {:ok, result :: term}
              | {:error, reason :: String.t()}

  @doc """
  Documentation for `worker`
  """
  @spec worker(module, non_neg_integer) ::
          {:ok, any}
          | {:error, any}
  def worker(worker_module, wid) do
    receive do
      {:work, arg} ->
        r = worker_module.work(arg)
        create(worker_module, wid) |> WorkerPool.alive(worker_module)
        r
    end
  end

  @doc """
  Documentation for `create`
  """
  @spec create(module, non_neg_integer) :: pid
  def create(worker_module, wid) do
    spawn(__MODULE__, :worker, [worker_module, wid])
  end

  defmacro __using__(_opts) do
  end
end
