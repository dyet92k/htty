require 'htty/cli/commands/path_set'
require 'htty/cli/commands/address'
require 'htty/cli/commands/cd'

RSpec.describe HTTY::CLI::Commands::PathSet do
  describe 'class' do
    let :klass do
      subject.class
    end

    it 'should be an alias_for the expected command' do
      expect(klass.alias_for).to eq(nil)
    end

    it 'should have the expected aliases' do
      expect(klass.aliases).to eq([HTTY::CLI::Commands::Cd])
    end

    it 'should belong to the expected category' do
      expect(klass.category).to eq('Navigation')
    end

    it 'should have the expected command_line' do
      expect(klass.command_line).to eq('path[-set]')
    end

    it 'should have the expected command_line_arguments' do
      expect(klass.command_line_arguments).to eq('PATH')
    end

    it 'should have the expected help' do
      expect(klass.help).to eq("Changes the path of the request's address")
    end

    it 'should have the expected help_extended' do
      expected = <<-end_help_extended
Changes the path used for the request. Does not communicate with the host.

The path will be URL-encoded if necessary.

The console prompt shows the address for the current request.
      end_help_extended
      expect(klass.help_extended).to eq(expected.chomp)
    end

    it 'should have the expected see_also_commands' do
      expect(klass.see_also_commands).to eq([HTTY::CLI::Commands::Address])
    end

    describe 'build_for' do
      it 'should correctly handle a valid, unabbreviated command line' do
        built = klass.build_for('path-set foo', session: :the_session)
        expect(built).to be_instance_of(klass)
        expect(built.arguments).to eq(['foo'])
        expect(built.session).to eq(:the_session)
      end

      it 'should correctly handle a valid, abbreviated command line' do
        built = klass.build_for('path bar', session: :a_session)
        expect(built).to be_instance_of(klass)
        expect(built.arguments).to eq(['bar'])
        expect(built.session).to eq(:a_session)
      end

      it 'should correctly handle a command line with a bad command' do
        built = klass.build_for('x baz', session: :another_session)
        expect(built).to eq(nil)
      end

      it 'should correctly URL escape simple paths' do
        built = klass.build_for('path b@r', session: :a_session)
        expect(built).to be_instance_of(klass)
        expect(built.arguments).to eq(['b%40r'])
        expect(built.session).to   eq(:a_session)
      end

      it 'should correctly URL escape multi-part paths' do
        built = klass.build_for('path bar/baz', session: :a_session)
        expect(built).to be_instance_of(klass)
        expect(built.arguments).to eq(['bar/baz'])
        expect(built.session).to   eq(:a_session)
      end

      it 'should correctly URL escape multi-part paths containing special characters' do
        built = klass.build_for('path b@r/ba{', session: :a_session)
        expect(built).to be_instance_of(klass)
        expect(built.arguments).to eq(['b%40r/ba%7B'])
        expect(built.session).to   eq(:a_session)
      end

      it 'should correctly URL escape multi-part paths containing escaped slashes' do
        built = nil
        expect {
          built = klass.build_for('path b@r/b%2Fz', session: :a_session)
        }.to print_on_stdout <<-end_stdout
*** Argument 'b%2Fz' was not URL-escaped because it contains escape sequences
        end_stdout
        expect(built).to be_instance_of(klass)
        expect(built.arguments).to eq(['b%40r/b%2Fz'])
        expect(built.session).to   eq(:a_session)
      end
    end
  end
end
