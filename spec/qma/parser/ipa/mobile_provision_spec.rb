describe QMA::Parser::MobileProvision do
  let(:file) { File.dirname(__FILE__) + '/../../../fixtures/apps/ipad.ipa' }
  let(:ipa) { QMA::Parser::IPA.new(file) }
  subject { QMA::Parser::MobileProvision.new(ipa.mobileprovision_path) }

  if OS.mac?
    it { expect(subject.devices).to be_nil }
    it { expect(subject.team_name).to eq('QYER Inc') }
    it { expect(subject.profile_name).to eq('XC: *') }
    it { expect(subject.expired_date).not_to be_nil }
    it { expect(subject.mobileprovision).to be_kind_of Hash }
  end
end
