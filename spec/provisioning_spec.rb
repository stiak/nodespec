require 'nodespec/provisioning'

module NodeSpec
  describe Provisioning do
    let(:subject) {Object.new.extend Provisioning}
    let(:provisioner_instance){double('provisioner instance')}
    let(:provisioning_block) {Proc.new {}}
    
    before do
      allow(NodeSpec).to receive(:current_node).and_return('current node')
    end
    
    {
      'puppet' => Provisioning::Puppet,
      'chef' => Provisioning::Chef
    }.each do |name, clazz|
      it "instantiate the #{clazz} provisioner once only" do
        allow(clazz).to receive(:new).with('current node').once.and_return(provisioner_instance)
        expect(provisioner_instance).to receive(:instance_eval).twice

        subject.send("provision_node_with_#{name}", &provisioning_block)
        subject.send("provision_node_with_#{name}", &provisioning_block)
      end

      it "executes the #{clazz} command" do
        allow(clazz).to receive(:new).with('current node').and_return(provisioner_instance)
        expect(provisioner_instance).to receive(:instance_eval) do |&b|
          expect(b).to be provisioning_block
        end

        subject.send("provision_node_with_#{name}", &provisioning_block)
      end
    end
  end
end