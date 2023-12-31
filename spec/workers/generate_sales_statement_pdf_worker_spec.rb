require 'rails_helper' # include in your RSpec file
require 'sidekiq/testing' #include in your Rspec file
Sidekiq::Testing.fake! #include in your RSpec file

RSpec.describe GenerateSalesStatementPdfWorker, type: :job do
  describe 'sound check' do
    it 'jobs are enqueued in the scheduled queue' do
      described_class.perform_async
      assert_equal "default", described_class.queue
    end

    it 'perform the job' do
      described_class.new.perform
    end

    it 'should generate sales statement record for each workspace' do
      create_list(:workspace, 2)
      expect do
        described_class.new.perform
      end.to change(SalesStatement, :count).by(2)
    end
  end

  describe 'file' do
    it 'attaching file to sales statement' do
      workspace = create(:workspace)
      store = create(:store, workspace: workspace)
      coupon = create(:coupon, discount_by: 'percentage_discount', discount_percentage: 10, workspace: workspace)
      3.times do
        order = create(:order, :with_line_items, order_type: 'pos', workspace: workspace, store: store)
        create(:order_coupon, order: order, coupon: coupon)
        order.checkout!
        create(:payment, status: 'success', order: order, workspace: order.workspace, created_at: Faker::Time.between(from: Time.current.last_month.beginning_of_month, to: Time.current.last_month.end_of_month))
        order.complete!
      end
      
      expect do
        described_class.new.perform
      end.to change(SalesStatement, :count).by(1)

      expect(SalesStatement.last.file.url).to_not be_nil
    end
  end
end
