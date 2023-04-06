describe Fastlane::Actions::FlutterVersionSyncAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The flutter_version_sync plugin is working!")

      Fastlane::Actions::FlutterVersionSyncAction.run(nil)
    end
  end
end
