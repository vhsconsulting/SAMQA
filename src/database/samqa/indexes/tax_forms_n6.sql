create index samqa.tax_forms_n6 on
    samqa.tax_forms (
        end_date
    );


-- sqlcl_snapshot {"hash":"c25b9604be6b1610f80c815fbd67fdd73eb4231b","type":"INDEX","name":"TAX_FORMS_N6","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>TAX_FORMS_N6</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>TAX_FORMS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>END_DATE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}