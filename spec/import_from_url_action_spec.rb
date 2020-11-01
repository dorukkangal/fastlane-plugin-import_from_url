describe Fastlane::Actions::ImportFromUrlAction do
  describe '#run' do
    it 'prints a message' do
      Fastlane::Actions::ImportFromUrlAction.run(url: "https://raw.githubusercontent.com/dorukkangal/fastlane-plugin-import_from_url/master/fastlane/FastfileForTest")
    end
  end
end
