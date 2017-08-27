# coding: utf-8
class SavingsController < ApplicationController
  before_action :set_saving, only: [:show, :edit, :update, :destroy]
  # storepathのみシステム側で設定する
  #before_action :set_storepath, only: [:create]

  # GET /savings
  # GET /savings.json
  def index
    # @savings = Saving.all
    # @savings = Saving.page(params[:page]).order(:id)
    # indexであっても検索フォームを出すので、まずはnewメソッドでフォーム準備
    # そのあと、searchをコールして検索結果表示
    @saving = Search::Saving.new
  end
  def outputj
    @savings = Saving.all
  end
  def search
    @saving = Search::Saving.new(search_params)
#    @savings = Kaminari.paginate_array(@saving.matches.order(recdate: :desc).page(params[:page]))
    @savings = @saving.matches.order(recdate: :desc).page(params[:page])
#   for debug and JSON形式チェック
#   (ページが返ってしまう&CarrierWaveに汚染されたvideoフィールド)
#    render json: @savings
  end

  # GET /savings/1
  # GET /savings/1.json
  def show
  end
  # GET /savings/:id/downloadimg
  def downloadimg
    image = Saving.find(params[:id])
    pppath = "public" + image.video.url
    send_file( pppath)
  end

  # GET /savings/new
  def new
    @saving = Saving.new
  end

  # GET /savings/1/edit
  def edit
  end

  # POST /savings
  # POST /savings.json
  def create
    @saving = Saving.new(saving_params)

    # video_uploader.rbのstore_dirは、DBへのレコード登録後である
    # よって、savings_controller.rbでパスをDBセーブした値を持ってくる
    # そのパスは、ユニークになるよう秒までをディレクトリに含める
    # 注意：storepathは最後に/をつけない。

    pathpart = Date.today
    pathpart2 = Time.now
    pathconcat = "uploads/grpvideo/" + pathpart.strftime("%Y/%m/%d/") + pathpart2.strftime("%H%M%S")
    @saving.storepath = sprintf("%s",pathconcat)

    respond_to do |format|
      if @saving.save
        format.html { redirect_to @saving, notice: 'Saving was successfully created.' }
        format.json { render :show, status: :created, location: @saving }
      else
        format.html { render :new }
        format.json { render json: @saving.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /savings/1
  # PATCH/PUT /savings/1.json
  def update
    respond_to do |format|
      if @saving.update(saving_params)
        format.html { redirect_to @saving, notice: 'Saving was successfully updated.' }
        format.json { render :show, status: :ok, location: @saving }
      else
        format.html { render :edit }
        format.json { render json: @saving.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /savings/1
  # DELETE /savings/1.json
  def destroy
    @saving.destroy
    respond_to do |format|
      format.html { redirect_to savings_url, notice: 'Saving was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  # 2016.12.16 only insert records to DB. because jpeg files are
  #  uploaded by anathoer application. So ,inputs are full-path jpeg
  #  files list,then bulk insert into DB.
  def registdb
    # 【準備】登録用配列準備
    # バルク登録するため、columnsはフィールド名、valuesはレコードの配列準備
    columns = [:storepath, :video, :title, :owner, :recdate ]
    @svalues = []
    # valuesの説明。process_file()にて登録すべきレコードを以下のように
    # values.pushしておく。
    # values << [ "aapath", "aafile", "aatitle", "aaowner", Date.today]
    # values << [ "bbpath", "bbfile", "bbtitle", "bbowner", Date.today]
    # そして最後の最後に以下の1行でバルクインサートする。
    # registdb一番後ろでSaving.import(columns, values, validate: false)

    # 【主処理1】指定ディレクトリのファイル群でループして【副処理】実施
    # p Dir.pwd : 結果は、/vagrant/rails420/grpvideo_420U_plus2
    # カレントディレクトリからpublicに降りてパスを得る
    # Dir.chdir("xxx")do 処理 end とすれば、プログラム実行カレント
    # ディレクトリを変更せず、ブロック内だけで処理できる。
    # uploads2から始まるフルパスが得られるわけだ。
    Dir.chdir("public") do
      processing_dir='uploads2' # 将来これは引数で
      # uploads2以下すべてのディレクトリのすべてのファイルに
      # process_file処理
      Dir.glob(["#{processing_dir}/**/*"]).each do |dfname|
        unless File.directory?(dfname)
          process_file(dfname, @svalues) # ここで副処理へ
        end
      end
    end
    # カレントディレクトリからpublicに降りてパスを得た(ここまで)
    # 【主処理2=LAST】DBへバルクインサート

    Saving.import(columns, @svalues, validate: false)

  end

  ##private private private private private start
  private
    # registdb内部で使用する関数
    # 【副処理スタート】
    def process_file(gotpath, values)
      ###########@saving = Saving.new()
      # gotpathは、uploads2/XX/XX.*
      kakuchoshi = File.extname(gotpath)
      case kakuchoshi
      when ".jpeg", ".jpg", ".JPEG", ".JPG"
        # 【副処理1】ヒットした写真1ファイルに対する処理スタート
        # "uploads2/aa/xx.jpeg"を例にコメントに結果を記述
        # dir_pathは"uploads2/aa" つまりstorepathに入れる値になる
        dir_path = File.dirname(gotpath)
        fnamebase = File.basename(gotpath,kakuchoshi) # "xx"
        fname = File.basename(gotpath) # "xx.jpeg"
        # 【副処理2】対象ファイルがDBに登録されているなら何もしない。
        # find_byは、LIMIT 1つまり1レコードあったらそこで止める。
        @saving = Saving.find_by(storepath: dir_path, video: fname)
        if (@saving.nil?)
          # このgotpathは登録対象である(DBがnilつまりDBにない為)
          # 【副処理3】storepath,videoをセット。他を一応初期値NULLに
          p1 = dir_path # :storepath
          p2 = fname # :video
          p3 = "notitle" # :title
          p4 = "nobody" # :owner
          p5 = Date.today # :recdate
          # 【副処理4】属性p3,p4をjsonファイルから取得
          fulljsonfilename = dir_path + '/' + fnamebase + '.json'
          File.open(fulljsonfilename) do |jfile|
            hash = JSON.load(jfile)
            p3 = hash["title"]
            p4 = hash["owner"]
          end
          #p3 = hash["title"]
          #p4 = hash["owner"]
          # 【副処理5】取得した値をvaluesにセット
          values << [ p1, p2, p3, p4, p5 ]

        end # if(@saving...) end
      end # case end
    end # process_file end
    # 【副処理エンド】
    # ###### registdb private function process_file end

    # Use callbacks to share common setup or constraints between actions.
    def set_saving
      @saving = Saving.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def saving_params
      params.require(:saving).permit(:recdate, :title, :owner, :note, :video, :video_cache, :storepath)
    end
    def search_params
      params
        .require(:search_saving)
        .permit(Search::Saving::ATTRIBUTES)
    end
    # ファイル登録時のみ、パスを自動生成し、フィールドstorepathにセット
  ##private private private private private end

end
