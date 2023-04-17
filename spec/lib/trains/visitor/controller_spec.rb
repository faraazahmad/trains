describe Trains::Visitor::Controller do
  let(:valid_controller) do
    File.expand_path "#{__FILE__}/../../../../fixtures/box_controller.rb"
  end

  context "Given a valid controller file path" do
    it "returns an object with its metadata" do
      puts Dir.pwd
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          valid_controller,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to have_attributes(
        name: "BoxController",
        method_list: [
          Trains::DTO::Method.new(name: "create"),
          Trains::DTO::Method.new(name: "edit"),
          Trains::DTO::Method.new(name: "update"),
          Trains::DTO::Method.new(name: "destroy")
        ]
      )
    end
  end
end
