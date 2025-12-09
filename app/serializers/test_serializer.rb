class TestSerializer
  def initialize(test)
    @test = test
  end

  def as_json(*)
    {
      id: @test.id,
      title: @test.title,
      description: @test.description,
      start_at: @test.start_at,
      end_at: @test.end_at,
      status: @test.status,
      is_destroyed: @test.is_destroyed,
      examinee_count: @test.examinee_count,
      actant_id: @test.actant_id,
      created_at: @test.created_at,
      updated_at: @test.updated_at
    }
  end
end