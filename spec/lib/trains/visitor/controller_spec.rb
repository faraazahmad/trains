describe Trains::Visitor::Controller do
  let(:valid_controller) { 'spec/fixtures/box_controller.rb' }

  context 'Given a valid controller file path' do
    it 'returns an object with its metadata' do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          valid_controller,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to eq(
        Trains::DTO::Controller.new(
          name: 'BoxController',
          method_list: Set[
            Trains::DTO::Method.new(name: 'create', visibility: nil, source: nil),
            Trains::DTO::Method.new(name: 'edit', visibility: nil, source: nil),
            Trains::DTO::Method.new(name: 'update', visibility: nil, source: nil),
            Trains::DTO::Method.new(name: 'destroy', visibility: nil, source: nil),
          ]
        )
      )
    end
  end
end
