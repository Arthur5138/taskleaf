class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    #@tasks = current_user.tasks.order(created_at: :desc)
    @q = current_user.tasks.ransack(params[:q])
    @tasks = @q.result(distinct: true).page(params[:page]).per(10).order(created_at: :desc)

    respond_to do |format|
      format.html
      format.csv { send_data @tasks.generate_csv, filename: "tasks-#{Time.zone.now.strftime('%Y%m%d%S')}.csv" }
    end
  end

  def show
    #@task = current_user.tasks.find(params[:id])
  end

  def new
    @task = Task.new
  end

  def create
    # task = Task.new(task_params)
    # task.save!
    # redirect_to tasks_url, notice: "#{task.name}を登録しました。"
    #@task = Task.new(task_params)
    @task = current_user.tasks.build(task_params)

    if params[:back].present?
      render :new
      return
    end

     if @task.save
       #logger.debug "task: #{@task.attributes.inspect}"
       TaskMailer.creation_email(@task).deliver_now
       SampleJob.perform_later
       #SampleJob.set(wait_until: Date.tomorrow.noon).perform_later
       redirect_to @task, notice: "#{@task.name}を登録しました。"
     else
       render :new
     end
  end

  def edit
    #@task = current_user.tasks.find(params[:id])
    #@task = Task.find(params[:id])
  end

  def update
    #task = Task.find(params[:id])
    #@task = current_user.tasks.find(params[:id])
    @task.update!(task_params)
    redirect_to tasks_url, notice: "「#{@task.name}」を更新しました。"
  end

  def destroy
    #task = Task.find(params[:id])
    #@task = current_user.tasks.find(params[:id])
    @task.destroy
    #redirect_to tasks_url, notice: "「#{@task.name}」を削除しました。"
  end

  def confirm_new
    @task = current_user.tasks.new(task_params)
    render :new unless @task.valid?
  end

  def import
    current_user.tasks.import(params[:file])
    redirect_to tasks_url, notice: "タスクを追加しました"
  end

  private

  def task_params
    params.require(:task).permit(:name, :description, :image)
  end

  def set_task
    @task = current_user.tasks.find(params[:id])
  end
end
