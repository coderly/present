require 'present/entity'
require 'pry'

module Present
  describe Entity do

    let(:basic) do
      Class.new(Entity) do
        expose :name
        expose :age
      end
    end

    let(:object) { double(:user, name: 'Bob', age: 5, gender: 'f') }
    let(:presentable) { basic.new(object) }
    subject { presentable }

    its(:name) { should eq 'Bob' }
    its(:age) { should eq 5 }
    it { should_not respond_to :gender }

    its(:to_h) { should include :name, :age }
    its(:to_h) { should_not include :gender }

    it 'should do the same thing with represent' do
      basic.represent(object).should == {name: 'Bob', age: 5}
    end

    it 'should return nil when presenting nil' do
      basic.represent(nil).should be_nil
    end

    describe 'expose with' do
      let(:basic) do
        user_entity = Class.new(Entity) do
          def self.who
            'user entity'
          end

          def first_name
            "<#{object}>"
          end

          def current_user_from_env
            env['foo-auth.current_user']
          end
        end

        Class.new(Entity) do
          def self.who
            'main entity'
          end

          expose :user, with: user_entity
          expose :friends, with: user_entity
        end
      end

      it 'should wrap the user with the user_entity' do
        result = basic.represent({ user: 'jack', friends: ['kate', 'jill'] })

        result[:user][:first_name].should eq '<jack>'
        result[:friends][0][:first_name].should eq '<kate>'
        result[:friends][1][:first_name].should eq '<jill>'
      end

      it 'should pass the env down to embedded entities' do
        env = { 'foo-auth.current_user' => 'Bruce Li'}
        result = basic.represent({ user: 'jack', friends: ['holly'] }, {env: env})
        result[:friends][0][:current_user_from_env].should eq 'Bruce Li'
      end
    end

    describe 'presentable that inherits' do
      let(:inherited) do
        Class.new(basic) do
          def gender
            object.gender.upcase
          end
        end
      end
      let(:presentable) { inherited.new(object) }
      subject { presentable }

      its(:name) { should eq 'Bob' }
      its(:age) { should eq 5 }
      its(:gender) { should eq 'F' }

      its(:to_h) { should include :name, :age, :gender }
    end

    context 'when passing in options to represent' do
      let(:entity_class) do
        Class.new(Entity) do
          def food
            options[:fruit].upcase
          end
        end
      end

      it 'should be assigned to the options variable' do
        result = entity_class.represent([double], fruit: 'pear')
        result.should eq [{food: 'PEAR'}]
      end

    end

    context 'when passing in the current user to the env' do
      let(:entity_class) do
        Class.new(Entity) do
          def username
            current_user ? current_user.name : 'anonymous'
          end
        end
      end

      it 'should be assigned the current_user properly' do
        user = Object.new
        def user.name; "chuck" end
        env = {'auth.current_user' => user}
        result = entity_class.represent([double], env: env)
        result.should eq [{username: 'chuck'}]
      end

      it 'should not choke when the current user isnt present' do
        result = entity_class.represent([double])
        result.should eq [{username: 'anonymous'}]
      end
    end

  end
end
