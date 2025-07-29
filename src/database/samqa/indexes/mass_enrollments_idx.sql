create index samqa.mass_enrollments_idx on
    samqa.mass_enrollments (
        batch_number
    );


-- sqlcl_snapshot {"hash":"1555f2a3b61dd778e3e04cdb7217f8dc0d97e72e","type":"INDEX","name":"MASS_ENROLLMENTS_IDX","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>MASS_ENROLLMENTS_IDX</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>MASS_ENROLLMENTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>BATCH_NUMBER</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}