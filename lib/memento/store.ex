use Amnesia

defdatabase Memento.Store do
  deftable Entry, [:id, :type, :content, :timestamp], type: :set, index: [:type] do
    @type type :: :twitter_fav | :pinboard_link | :github_star

    @type t :: %Entry{
            id: String.t(),
            type: type,
            content: map(),
            timestamp: DateTime.t()
          }
  end
end
