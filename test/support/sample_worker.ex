defmodule SampleWorker do
  use WorkerPool.Worker

  @impl true
  def work(pid), do: {:ok, send(pid, :ok)}
end
