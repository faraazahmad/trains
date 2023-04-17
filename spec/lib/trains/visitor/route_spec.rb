describe Trains::Visitor::Route do
  let(:valid_controller) do
    File.expand_path "#{__FILE__}/../../../../fixtures/routes.rb"
  end

  context "Given a valid route file path" do
    it "returns an object with its metadata" do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          valid_controller,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to eq(
        [
          Trains::DTO::Route.new(method: :resources, param: :cats, options: {}),
          Trains::DTO::Route.new(
            method: :get,
            param: "/boxes",
            options: {
              to: "BoxController#index",
              as: "list_boxes"
            }
          )
        ]
      )
    end
  end
end
