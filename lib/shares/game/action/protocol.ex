defprotocol Shares.Game.Action.Protocol do
  def preload(action, game)
  def execute(action, game)
  # See Game.undo/1 for details
  # def undo(action, game)
end
