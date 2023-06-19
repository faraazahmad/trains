describe Trains::Visitor::Controller do
  let(:box_controller) do
    File.expand_path "#{__FILE__}/../../../../fixtures/box_controller.rb"
  end

  let(:health_controller) do
    File.expand_path "#{__FILE__}/../../../../fixtures/health_controller.rb"
  end

  context 'Given a valid controller file path' do
    it 'returns an object with its metadata' do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          box_controller,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to have_attributes(
        name: 'BoxController',
        method_list: [
          Trains::DTO::Method.new(name: 'create'),
          Trains::DTO::Method.new(name: 'edit'),
          Trains::DTO::Method.new(name: 'update'),
          Trains::DTO::Method.new(name: 'destroy')
        ],
        callbacks: [
          Trains::DTO::Callback.new(method: :http_basic_authenticate_with, arguments: [{
                                      name: 'dhh',
                                      password: 'secret',
                                      except: :index
                                    }])
        ]
      )
    end

    it 'returns an object with its metadata' do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          health_controller,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to have_attributes(
        name: 'HealthController',
        method_list: [
          Trains::DTO::Method.new(name: 'show')
        ],
        callbacks: []
      )
    end
  end
end
