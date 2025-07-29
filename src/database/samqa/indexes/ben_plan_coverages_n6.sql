create index samqa.ben_plan_coverages_n6 on
    samqa.ben_plan_coverages (
        coverage_tier_name
    );


-- sqlcl_snapshot {"hash":"a9c1df99c5aa91fceb772e2650fbfdd003690657","type":"INDEX","name":"BEN_PLAN_COVERAGES_N6","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>BEN_PLAN_COVERAGES_N6</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>BEN_PLAN_COVERAGES</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>COVERAGE_TIER_NAME</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}