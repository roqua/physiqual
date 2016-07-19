module Physiqual
  require 'rails_helper'
  describe CassandraConnection do
    describe 'initialize' do
    end

    describe 'with mock connection' do
      let(:user_id) { 0 }
      let(:year) { 2016 }
      let(:from) { 3.days.ago }
      let(:to) { Time.now }
      let(:arguments_array) { [user_id, year, from, to] }

      before(:each) do
        @cluster =  double('cluster')
        @session =  double('session')
        query =  double('query')
        insert_query = double('insert_query')

        @queries = { 'heart_rate' => query,
                     'sleep' => query,
                     'calories' => query,
                     'distance' => query,
                     'steps' => query,
                     'activities' => query }

        @insert_queries = { 'heart_rate' => insert_query,
                            'sleep' => insert_query,
                            'calories' => insert_query,
                            'distance' => insert_query,
                            'steps' => insert_query,
                            'activities' => insert_query }

        allow(@cluster).to receive(:connect).and_return(@session)
        allow(Cassandra).to receive(:cluster).with(any_args).and_return(@cluster)
        allow_any_instance_of(described_class).to receive(:initialize_database).and_return(true)

        described_class.instance.instance_variable_set(:@queries, @queries)
        described_class.instance.instance_variable_set(:@insert_queries, @insert_queries)
      end

      describe 'insert' do
        it "should insert data in the database in batches" do
          expect(true).to eq false
        end

        it "should be able to work with nil values" do
          expect(true).to eq false
        end

        it 'should convert values to big decimal values if needed' do

        end
      end

      describe 'query_heart_rate' do
        it 'calls the execute method on the session object' do
          var_name = 'heart_rate'
          session = double('session')
          expect(session).to receive(:execute).with(@queries[var_name], arguments: arguments_array)
          described_class.instance.instance_variable_set(:@session, session)
          described_class.instance.query_heart_rate(user_id, year, from, to)
        end
      end

      describe 'query_sleep' do
        it 'calls the execute method on the session object' do
          var_name = 'sleep'
          session = double('session')
          expect(session).to receive(:execute).with(@queries[var_name], arguments: arguments_array)
          described_class.instance.instance_variable_set(:@session, session)
          described_class.instance.query_sleep(user_id, year, from, to)
        end
      end

      describe 'query_calories' do
        it 'calls the execute method on the session object' do
          var_name = 'calories'
          session = double('session')
          expect(session).to receive(:execute).with(@queries[var_name], arguments: arguments_array)
          described_class.instance.instance_variable_set(:@session, session)
          described_class.instance.query_heart_rate(user_id, year, from, to)
        end
      end

      describe 'query_distance' do
        it 'calls the execute method on the session object' do
          var_name = 'distance'
          session = double('session')
          expect(session).to receive(:execute).with(@queries[var_name], arguments: arguments_array)
          described_class.instance.instance_variable_set(:@session, session)
          described_class.instance.query_distance(user_id, year, from, to)
        end
      end

      describe 'query_steps' do
        it 'calls the execute method on the session object' do
          var_name = 'steps'
          session = double('session')
          expect(session).to receive(:execute).with(@queries[var_name], arguments: arguments_array)
          described_class.instance.instance_variable_set(:@session, session)
          described_class.instance.query_steps(user_id, year, from, to)
        end
      end

      describe 'query_activities' do
        it 'calls the execute method on the session object' do
          var_name = 'activities'
          session = double('session')
          expect(session).to receive(:execute).with(@queries[var_name], arguments: arguments_array)
          described_class.instance.instance_variable_set(:@session, session)
          described_class.instance.query_activities(user_id, year, from, to)
        end
      end

      # private methods

      describe 'slice' do
        let!(:times) { [1, 2, 3, 4, 5, 6] }
        let(:start_dates) { [6, 5, 4, 3, 2, 1] }
        let(:end_dates) { %w(a c d e f) }
        let(:values) { %w(f e d c b a) }
        let(:number_of_variables) { 4 }
        let(:number_of_entries) { times.length }
        it 'should slice the provided arrays in the slice_size' do
          stub_const('Physiqual::CassandraConnection::SLICE_SIZE', 2)
          expect(described_class::SLICE_SIZE).to eq(2)
          res = described_class.instance.send(:slice, times, start_dates, end_dates, values)
          res.each { |x| expect(x.length).to eq((number_of_entries.to_f / described_class::SLICE_SIZE.to_f).ceil) }
        end

        it 'should be able to deal with SLICE_SIZE > then the number of entries' do
          res = described_class.instance.send(:slice, times, start_dates, end_dates, values)
          expect(res.length).to eq(number_of_variables)
          res.each { |x| expect(x.length).to eq((number_of_entries.to_f / described_class::SLICE_SIZE.to_f).ceil) }
        end
      end

      describe 'initialize_database' do
        before(:each) do
          allow_any_instance_of(described_class).to receive(:initialize_database).and_call_original
        end

        let(:variables) do
          { 'heart_rate' => 'decimal',
            'sleep' => 'decimal',
            'calories' => 'decimal',
            'distance' => 'decimal',
            'steps' => 'decimal',
            'activities' => 'varchar' }
        end
        it 'should initialize the insert queries' do
          variables.each do |variable, _type|
            allow(described_class.instance).to receive(:prepare_query).with(any_args)
            allow(described_class.instance).to receive(:create_table).with(any_args)
            expect(described_class.instance).to receive(:prepare_insert).with(variable)
          end
          described_class.instance.send(:initialize_database, variables)
        end

        it 'should initialize the retrieve queries' do
          variables.each do |variable, _type|
            expect(described_class.instance).to receive(:prepare_query).with(variable)
            allow(described_class.instance).to receive(:create_table).with(any_args)
            allow(described_class.instance).to receive(:prepare_insert).with(any_args)
          end
          described_class.instance.send(:initialize_database, variables)
        end

        it 'should initialize the tables' do
          variables.each do |variable, type|
            allow(described_class.instance).to receive(:prepare_query).with(any_args)
            expect(described_class.instance).to receive(:create_table).with(variable, type)
            allow(described_class.instance).to receive(:prepare_insert).with(any_args)
          end
          described_class.instance.send(:initialize_database, variables)
        end
      end

      describe 'prepare_insert' do
        it 'should use the provided name in the query' do
          table_name = 'some random variable name'
          qry = "INSERT INTO #{table_name} (user_id, year, time, start_date, end_date, value) VALUES (?, ?, ?, ?, ?, ?)"

          session = double('session')
          expect(session).to receive(:prepare).with(qry)
          described_class.instance.instance_variable_set(:@session, session)
          described_class.instance.send(:prepare_insert, table_name)
        end
      end

      describe 'prepare_query' do
        it 'should use the provided name in the query' do
          table_name = 'some random variable name'
          qry = "
          SELECT time, start_date, end_date, value
          FROM #{table_name}
          WHERE user_id = ? AND year = ? AND time >= ? AND time <= ?
          ORDER BY time ASC
        "
          session = double('session')
          expect(session).to receive(:prepare).with(qry)
          described_class.instance.instance_variable_set(:@session, session)
          described_class.instance.send(:prepare_query, table_name)
        end
      end

      describe 'create_table' do
        it 'should use the provided name in the query' do
          name = 'some random variable name'
          value_type = 'some random variable type'
          query = "
            CREATE TABLE IF NOT EXISTS #{name} (
            user_id text, year int, time timestamp, start_date timestamp, end_date timestamp, value #{value_type},
            PRIMARY KEY ((user_id, year), time)
          )
        "
          session = double('session')
          expect(session).to receive(:execute).with(query)
          described_class.instance.instance_variable_set(:@session, session)
          described_class.instance.send(:create_table, name, value_type)
        end
      end
    end
  end
end
