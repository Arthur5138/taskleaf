require 'rails_helper'

describe 'タスク管理機能', type: :system do
  #ユーザーのletを作成しておく
  let(:user_a) { FactoryBot.create(:user, name: 'ユーザーA', email: 'a@example.com') }
  let(:user_b) { FactoryBot.create(:user, name: 'ユーザーB', email: 'b@example.com') }
  let!(:task_a) { FactoryBot.create(:task, name: '最初のタスク', user: user_a) }

  before do
    #作成者がユーザーAであるタスクを作成しておく
    #FactoryBot.create(:task, name: '最初のタスク', user: user_a)

    #ログイン画面にアクセスする
    visit login_path
    #メールアドレスを入力する
    fill_in 'メールアドレス', with: login_user.email
    #パスワードを入力する
    fill_in 'パスワード', with: login_user.password
    #ログインボタンを押す
    click_button 'ログインする'
  end

  shared_examples_for 'ユーザーAが作成したタスクが表示される' do
    it { expect(page).to have_content '最初のタスク' }
  end


  describe '一覧表示機能' do

   context 'ユーザーAがログインしている時' do

    let(:login_user) { user_a }
    # it 'ユーザーAが作成したタスクが表示される' do
    #   #作成済みのタスクが画面上に表示される
    #   expect(page).to have_content '最初のタスク'
    # end
    it_behaves_like 'ユーザーAが作成したタスクが表示される'

   end

   context 'ユーザーBがログインしている時' do

     let(:login_user) { user_b }

     it 'ユーザーAが作成したタスクが表示されない' do
       #ユーザーAが作成したタスクが画面上に表示されない。
       expect(page).to have_no_content '最初のタスク'
     end
   end
  end

  describe '詳細表示機能' do
    context 'ユーザーAがログインしている時' do
      let(:login_user) { user_a }

      before do
      visit task_path(task_a)
      end

      # it 'ユーザーAが作成したタスクが表示される' do
      #   expect(page).to have_content '最初のタスク'
      # end
      it_behaves_like 'ユーザーAが作成したタスクが表示される'
    end
  end

  describe '新規タスク作成機能' do
    let(:login_user) { user_a }

    before do
      visit new_task_path
      fill_in '名称', with: task_name
      click_button '登録する'
    end

    context '新規作成画面で名称を入力した時' do
      let(:task_name) { '新規作成のテストをかく'}
      it '正常に登録される' do
        expect(page).to have_selector '.alert-success', text: '新規作成のテストをかく'
      end
    end

    context '新規作成画面で名称を入力しない時' do
      let(:task_name) { '' }
      it 'エラーになる' do
        within '#error_explanation' do
          expect(page).to have_content '名称を入力してください'
        end
      end
    end
  end
end
