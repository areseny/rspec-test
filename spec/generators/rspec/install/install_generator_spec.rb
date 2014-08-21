require 'spec_helper'
require 'generators/rspec/install/install_generator'

describe Rspec::Generators::InstallGenerator, :type => :generator do
  destination File.expand_path("../../../../../tmp", __FILE__)

  def check_active_record_schema
    match(/ActiveRecord::Migration\./m)
  end

  def check_pending_migrations
    match(/ActiveRecord::Migration\.check_pending!/m)
  end

  def content_for(file_name)
    File.read(file(file_name))
  end

  def have_a_fixture_path
    match(/config\.fixture_path/m)
  end

  def maintain_test_schema
    match(/ActiveRecord::Migration\.maintain_test_schema!/m)
  end

  def require_rspec_rails
    match(/^require 'rspec\/rails'$/m)
  end

  def use_transactional_fixtures
    match(/config\.use_transactional_fixtures/m)
  end

  before { prepare_destination }

  let(:rails_helper) { content_for('spec/rails_helper.rb') }
  let(:spec_helper) { content_for('spec/spec_helper.rb') }

  it "generates .rspec" do
    run_generator
    expect(file('.rspec')).to exist
  end

  it "generates spec/spec_helper.rb" do
    generator_command_notice = / This file was generated by the `rails generate rspec:install` command./m
    run_generator
    expect(spec_helper).to match(generator_command_notice)
  end

  context "generates spec/rails_helper.rb" do
    specify "requiring respec/rails" do
      run_generator
      expect(rails_helper).to require_rspec_rails
    end

    specify "with transactional fixtures" do
      run_generator
      expect(rails_helper).to have_a_fixture_path
    end

    specify "with default fixture path" do
      run_generator
      expect(rails_helper).to use_transactional_fixtures
    end

    case ::Rails::VERSION::STRING.to_f
    when 4.1
      specify "checking for maintaining the schema" do
        run_generator
        expect(rails_helper).to maintain_test_schema
      end
    when 4.0
      specify "checking for pending migrations" do
        run_generator
        expect(rails_helper).to check_pending_migrations
      end
    else
      specify "without a check for pending migrations" do
        run_generator
        expect(rails_helper).not_to check_active_record_schema
      end
    end
  end

  context "generates spec/rails_helper.rb", "without ActiveRecord available" do
    before do
      hide_const("ActiveRecord")
    end

    it "requires respec/rails" do
      run_generator
      expect(rails_helper).to require_rspec_rails
    end

    it "does not include config.fixture_path" do
      run_generator
      expect(rails_helper).not_to have_a_fixture_path
    end

    it "does not include config.use_transactional_fixtures" do
      run_generator
      expect(rails_helper).not_to use_transactional_fixtures
    end

    case ::Rails::VERSION::STRING.to_f
    when 4.1
      it "does not check for maintaining test schema" do
        run_generator
        expect(rails_helper).not_to maintain_test_schema
        expect(rails_helper).not_to check_active_record_schema
      end
    when 4.0
      it "does not check for pending migrations" do
        run_generator
        expect(rails_helper).not_to check_pending_migrations
        expect(rails_helper).not_to check_active_record_schema
      end
    else
      it "does not check for pending migrations" do
        run_generator
        expect(rails_helper).not_to check_active_record_schema
      end
    end
  end

end
