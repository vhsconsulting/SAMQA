create or replace package body samqa.xml_chart_pkg as
/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    function function_exists (
        function_name in varchar2
    ) return boolean is
        v_f varchar2(1);
    begin
        select
            1
        into v_f
        from
            user_procedures
        where
            object_name = upper(function_name);

        return true;
    exception
        when others then
            return false;
    end function_exists;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    procedure delete_coll_pr (
        coll_name_in varchar2
    ) is
    begin
        if htmldb_collection.collection_exists(p_collection_name => coll_name_in) then
            htmldb_collection.delete_collection(p_collection_name => coll_name_in);
        end if;
    end delete_coll_pr;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    function to_number_fn (
        value_in varchar2
    ) return boolean is
        v_number number;
    begin
        v_number := to_number ( value_in );
        if v_number is not null then
            return true;
        else
            return false;
        end if;
    exception
        when others then
            return false;
    end to_number_fn;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    procedure chart_values_xml_pr (
        app_user_in            in varchar2,
        app_id_in              in varchar2,
        session_id_in          in varchar2,
        page_id_in             in varchar2,
        coll_name_in           in varchar2,
        chart_type_in          in varchar2,
        debug_xml_in           in varchar2,
        xml_filename_in        in varchar2,
        xml_output_dir_name_in in varchar2,
        sort_series_in         in varchar2,
        turn_caching_on_in     in varchar2
    ) is
        scatter_series_counter number;
        chart_values_out       varchar2(32767);
        v_error                varchar2(4000);
    begin
        htmldb_custom_auth.define_user_session(app_user_in, session_id_in);
        htmldb_application.g_flow_id := app_id_in;
        htmldb_custom_auth.post_login(app_user_in, session_id_in, app_id_in
                                                                  || ':'
                                                                  || page_id_in);
        if chart_type_in not in ( 'pie', '3d pie', 'floating bar', 'floating column', 'candlestick',
                                  'scatter' ) then
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*                    COMMON CHART   -   ALL OTHER CHART TYPES                          */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
            htp.p('<chart_data>');
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<chart_data>';
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select distinct
                    ( a.c002 ) c002,
                    b.seq_id
                from
                    htmldb_collections a,
                    (
                        select
                            min(seq_id) seq_id,
                            c002
                        from
                            htmldb_collections
                        where
                            collection_name = coll_name_in
                        group by
                            c002
                    )                  b
                where
                        a.c002 = b.c002
                    and a.collection_name = coll_name_in
                order by
                    b.seq_id
            ) loop
                htp.p('<string>'
                      || c.c002
                      || '</string>');
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || nvl(c.c002, 'Series')
                                    || '</string>';

            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

/****************************************************************************************/
/*                      If sorting of series is ASC.                                    */
/****************************************************************************************/
            if upper(sort_series_in) = 'ASC' then
                for c in (
                    select distinct
                        ( a.c001 ) c001,
                        b.seq_id
                    from
                        htmldb_collections a,
                        (
                            select
                                min(seq_id) seq_id,
                                c001
                            from
                                htmldb_collections
                            where
                                collection_name = coll_name_in
                            group by
                                c001
                        )                  b
                    where
                            a.c001 = b.c001
                        and a.collection_name = coll_name_in
                    order by
                        c001 asc
                ) loop
                    htp.p('<row>');
                    htp.p('<string>'
                          || c.c001
                          || '</string>');
                    chart_values_out := chart_values_out || '<row>';
                    chart_values_out := chart_values_out
                                        || '<string>'
                                        || c.c001
                                        || '</string>';
                    for d in (
                        select
                            a.c002,
                            nvl(b.c003, 0) c003
                        from
                            (
                                select distinct
                                    ( a.c002 ) c002,
                                    b.seq_id
                                from
                                    htmldb_collections a,
                                    (
                                        select
                                            min(seq_id) seq_id,
                                            c002
                                        from
                                            htmldb_collections
                                        where
                                            collection_name = coll_name_in
                                        group by
                                            c002
                                    )                  b
                                where
                                        a.c002 = b.c002
                                    and a.collection_name = coll_name_in
                                order by
                                    b.seq_id
                            ) a,
                            (
                                select
                                    c002,
                                    c003
                                from
                                    htmldb_collections
                                where
                                        collection_name = coll_name_in
                                    and c001 = c.c001
                            ) b
                        where
                            a.c002 = b.c002 (+)
                        order by
                            a.seq_id
                    ) loop
                        chart_values_out := chart_values_out
                                            || '<number>'
                                            || d.c003
                                            || '</number>';
                        htp.p('<number>'
                              || d.c003
                              || '</number>');
                    end loop;

               /* This is end of the row data. */
                    htp.p('</row>');
                    chart_values_out := chart_values_out || '</row>';
                end loop;
/****************************************************************************************/
/*                      If sorting of series is DESC.                                   */
/****************************************************************************************/
            else
                for c in (
                    select distinct
                        ( a.c001 ) c001,
                        b.seq_id
                    from
                        htmldb_collections a,
                        (
                            select
                                min(seq_id) seq_id,
                                c001
                            from
                                htmldb_collections
                            where
                                collection_name = coll_name_in
                            group by
                                c001
                        )                  b
                    where
                            a.c001 = b.c001
                        and a.collection_name = coll_name_in
                    order by
                        c001 desc
                ) loop
                    htp.p('<row>');
                    htp.p('<string>'
                          || c.c001
                          || '</string>');
                    chart_values_out := chart_values_out || '<row>';
                    chart_values_out := chart_values_out
                                        || '<string>'
                                        || c.c001
                                        || '</string>';
                    for d in (
                        select
                            a.c002,
                            nvl(b.c003, 0) c003
                        from
                            (
                                select distinct
                                    ( a.c002 ) c002,
                                    b.seq_id
                                from
                                    htmldb_collections a,
                                    (
                                        select
                                            min(seq_id) seq_id,
                                            c002
                                        from
                                            htmldb_collections
                                        where
                                            collection_name = coll_name_in
                                        group by
                                            c002
                                    )                  b
                                where
                                        a.c002 = b.c002
                                    and a.collection_name = coll_name_in
                                order by
                                    b.seq_id
                            ) a,
                            (
                                select
                                    c002,
                                    c003
                                from
                                    htmldb_collections
                                where
                                        collection_name = coll_name_in
                                    and c001 = c.c001
                            ) b
                        where
                            a.c002 = b.c002 (+)
                        order by
                            a.seq_id
                    ) loop
                        chart_values_out := chart_values_out
                                            || '<number>'
                                            || d.c003
                                            || '</number>';
                        htp.p('<number>'
                              || d.c003
                              || '</number>');
                    end loop;

               /* This is end of the row data. */
                    htp.p('</row>');
                    chart_values_out := chart_values_out || '</row>';
                end loop;
            end if;

         /* This is end of the chart data. */
            htp.p('</chart_data>');
            chart_values_out := chart_values_out || '</chart_data>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*                                 PIE CHART                                            */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
        elsif chart_type_in in ( 'pie', '3d pie' ) then
            htp.p('<chart_data>');
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<chart_data>';
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select distinct
                    ( a.c001 ) c001,
                    b.seq_id
                from
                    htmldb_collections a,
                    (
                        select
                            min(seq_id) seq_id,
                            c001
                        from
                            htmldb_collections
                        where
                            collection_name = coll_name_in
                        group by
                            c001
                    )                  b
                where
                        a.c001 = b.c001
                    and a.collection_name = coll_name_in
                order by
                    b.seq_id
            ) loop
                htp.p('<string>'
                      || c.c001
                      || '</string>');
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || c.c001
                                    || '</string>';
            end loop;

            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            htp.p('</row>');
            htp.p('<row>');
            htp.p('<string>Series</string>');
            chart_values_out := chart_values_out || '</row>';
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<string>Series</string>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c002
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                htp.p('<number>'
                      || c.c002
                      || '</number>');
                chart_values_out := chart_values_out
                                    || '<number>'
                                    || c.c002
                                    || '</number>';
            end loop;

            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

         /* This is end of the row data. */
            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
         /* This is end of the chart data. */
            htp.p('</chart_data>');
            chart_values_out := chart_values_out || '</chart_data>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*                            FLOATING CHART                                            */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
        elsif chart_type_in in ( 'floating bar', 'floating column' ) then
            htp.p('<chart_data>');
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<chart_data>';
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c001
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                htp.p('<string>'
                      || c.c001
                      || '</string>');
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || c.c001
                                    || '</string>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            htp.p('<row>');
            htp.p('<string>'
                  || 'high'
                  || '</string>');
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out
                                || '<string>'
                                || 'high'
                                || '</string>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c002
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                htp.p('<number>'
                      || c.c002
                      || '</number>');
                chart_values_out := chart_values_out
                                    || '<number>'
                                    || c.c002
                                    || '</number>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            htp.p('<row>');
            htp.p('<string>'
                  || 'low'
                  || '</string>');
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out
                                || '<string>'
                                || 'low'
                                || '</string>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c003
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                htp.p('<number>'
                      || c.c003
                      || '</number>');
                chart_values_out := chart_values_out
                                    || '<number>'
                                    || c.c003
                                    || '</number>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

         /* This is end of the chart data. */
            htp.p('</chart_data>');
            chart_values_out := chart_values_out || '</chart_data>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*                            CANDLESTICK CHART                                         */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
        elsif chart_type_in in ( 'candlestick' ) then
            htp.p('<chart_data>');
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<chart_data>';
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c001
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                htp.p('<string>'
                      || c.c001
                      || '</string>');
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || c.c001
                                    || '</string>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            htp.p('<row>');
            htp.p('<string>'
                  || 'max'
                  || '</string>');
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out
                                || '<string>'
                                || 'max'
                                || '</string>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c002
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                htp.p('<number>'
                      || c.c002
                      || '</number>');
                chart_values_out := chart_values_out
                                    || '<number>'
                                    || c.c002
                                    || '</number>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            htp.p('<row>');
            htp.p('<string>'
                  || 'min'
                  || '</string>');
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out
                                || '<string>'
                                || 'min'
                                || '</string>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c003
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                htp.p('<number>'
                      || c.c003
                      || '</number>');
                chart_values_out := chart_values_out
                                    || '<number>'
                                    || c.c003
                                    || '</number>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            htp.p('<row>');
            htp.p('<string>'
                  || 'open'
                  || '</string>');
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out
                                || '<string>'
                                || 'open'
                                || '</string>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c004
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                htp.p('<number>'
                      || c.c004
                      || '</number>');
                chart_values_out := chart_values_out
                                    || '<number>'
                                    || c.c004
                                    || '</number>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            htp.p('<row>');
            htp.p('<string>'
                  || 'close'
                  || '</string>');
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out
                                || '<string>'
                                || 'close'
                                || '</string>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c005
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                htp.p('<number>'
                      || c.c005
                      || '</number>');
                chart_values_out := chart_values_out
                                    || '<number>'
                                    || c.c005
                                    || '</number>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

         /* This is end of the chart data. */
            htp.p('</chart_data>');
            chart_values_out := chart_values_out || '</chart_data>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*                            SCATTER CHART                                             */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
        elsif chart_type_in in ( 'scatter' ) then
            htp.p('<chart_data>');
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<chart_data>';
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            select
                count(distinct c001)
            into scatter_series_counter
            from
                htmldb_collections
            where
                collection_name = coll_name_in;

            for i in 1..scatter_series_counter loop
                htp.p('<string>'
                      || 'x'
                      || '</string>');
                htp.p('<string>'
                      || 'y'
                      || '</string>');
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || 'x'
                                    || '</string>';
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || 'y'
                                    || '</string>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select distinct
                    ( a.c001 ) c001,
                    b.seq_id
                from
                    htmldb_collections a,
                    (
                        select
                            min(seq_id) seq_id,
                            c001
                        from
                            htmldb_collections
                        where
                            collection_name = coll_name_in
                        group by
                            c001
                    )                  b
                where
                        a.c001 = b.c001
                    and a.collection_name = coll_name_in
                order by
                    b.seq_id
            ) loop
                htp.p('<row>');
                htp.p('<string>'
                      || c.c001
                      || '</string>');
                chart_values_out := chart_values_out || '<row>';
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || c.c001
                                    || '</string>';
                for d in (
                    select
                        c002,
                        c003
                    from
                        htmldb_collections
                    where
                            collection_name = coll_name_in
                        and c001 = c.c001
                    order by
                        seq_id
                ) loop
                    htp.p('<number>'
                          || d.c002
                          || '</number>');
                    htp.p('<number>'
                          || d.c003
                          || '</number>');
                    chart_values_out := chart_values_out
                                        || '<number>'
                                        || d.c002
                                        || '</number>';
                    chart_values_out := chart_values_out
                                        || '<number>'
                                        || d.c002
                                        || '</number>';
                end loop;

            /* This is end of the row data. */
                htp.p('</row>');
                chart_values_out := chart_values_out || '</row>';
                if debug_xml_in = 'Y' then
                    xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                    chart_values_out := null;
                end if;

            end loop;

         /* This is end of the chart data. */
            htp.p('</chart_data>');
            chart_values_out := chart_values_out || '</chart_data>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

        end if;

    exception
        when others then
            v_error := sqlerrm;
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(v_error, xml_filename_in, xml_output_dir_name_in);
                xml_chart_pkg.delete_coll_pr(coll_name_in);
            end if;

            xml_chart_pkg.delete_coll_pr(coll_name_in);
    end chart_values_xml_pr;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    procedure axis_values_xml_pr (
        app_user_in            in varchar2,
        app_id_in              in varchar2,
        session_id_in          in varchar2,
        page_id_in             in varchar2,
        coll_name_in           in varchar2,
        chart_type_in          in varchar2,
        debug_xml_in           in varchar2,
        xml_filename_in        in varchar2,
        xml_output_dir_name_in in varchar2,
        sort_series_in         in varchar2,
        turn_caching_on_in     in varchar2,
        axis_val_conv_function in varchar2
    ) is

        v_value_txt            varchar2(200);
        scatter_series_counter number;
        chart_values_out       varchar2(32767);
        v_error                varchar2(4000);
    begin
        htmldb_custom_auth.define_user_session(app_user_in, session_id_in);
        htmldb_application.g_flow_id := app_id_in;
        htmldb_custom_auth.post_login(app_user_in, session_id_in, app_id_in
                                                                  || ':'
                                                                  || page_id_in);
        if chart_type_in not in ( 'pie', '3d pie', 'floating bar', 'floating column', 'candlestick',
                                  'scatter' ) then
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*                    COMMON CHART   -   ALL OTHER CHART TYPES                          */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
            htp.p('<chart_value_text>');
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<chart_value_text>';
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select distinct
                    ( a.c002 ) c002,
                    b.seq_id
                from
                    htmldb_collections a,
                    (
                        select
                            min(seq_id) seq_id,
                            c002
                        from
                            htmldb_collections
                        where
                            collection_name = coll_name_in
                        group by
                            c002
                    )                  b
                where
                        a.c002 = b.c002
                    and a.collection_name = coll_name_in
                order by
                    b.seq_id
            ) loop
                htp.p('<null/>');
                chart_values_out := chart_values_out || '<null/>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

/****************************************************************************************/
/*                      If sorting of series is ASC.                                    */
/****************************************************************************************/
            if upper(sort_series_in) = 'ASC' then
                for c in (
                    select distinct
                        ( a.c001 ) c001,
                        b.seq_id
                    from
                        htmldb_collections a,
                        (
                            select
                                min(seq_id) seq_id,
                                c001
                            from
                                htmldb_collections
                            where
                                collection_name = coll_name_in
                            group by
                                c001
                        )                  b
                    where
                            a.c001 = b.c001
                        and a.collection_name = coll_name_in
                    order by
                        c001 asc
                ) loop
                    htp.p('<row>');
                    htp.p('<null/>');
                    chart_values_out := chart_values_out || '<row>';
                    chart_values_out := chart_values_out || '<null/>';
                    for d in (
                        select
                            a.c002,
                            nvl(b.c003, 0) c003
                        from
                            (
                                select distinct
                                    ( a.c002 ) c002,
                                    b.seq_id
                                from
                                    htmldb_collections a,
                                    (
                                        select
                                            min(seq_id) seq_id,
                                            c002
                                        from
                                            htmldb_collections
                                        where
                                            collection_name = coll_name_in
                                        group by
                                            c002
                                    )                  b
                                where
                                        a.c002 = b.c002
                                    and a.collection_name = coll_name_in
                                order by
                                    b.seq_id
                            ) a,
                            (
                                select
                                    c002,
                                    c003
                                from
                                    htmldb_collections
                                where
                                        collection_name = coll_name_in
                                    and c001 = c.c001
                            ) b
                        where
                            a.c002 = b.c002 (+)
                        order by
                            a.seq_id
                    ) loop
                        begin
                            execute immediate 'BEGIN SELECT '
                                              || axis_val_conv_function
                                              || '('
                                              || d.c003
                                              || ') INTO xml_chart_pkg.v_value_axis_text '
                                              || 'FROM dual; EXCEPTION WHEN OTHERS THEN '
                                              || 'xml_chart_pkg.v_value_axis_text '
                                              || ':= ''Nn'';END;';
                        exception
                            when others then
                                xml_chart_pkg.v_value_axis_text := 'Nn';
                        end;

                        v_value_txt := xml_chart_pkg.v_value_axis_text;
                        chart_values_out := chart_values_out
                                            || '<string>'
                                            || v_value_txt
                                            || '</string>';
                        htp.p('<string>'
                              || v_value_txt
                              || '</string>');
                    end loop;

               /* This is end of the row data. */
                    htp.p('</row>');
                    chart_values_out := chart_values_out || '</row>';
                end loop;
/****************************************************************************************/
/*                      If sorting of series is DESC.                                   */
/****************************************************************************************/
            else
                for c in (
                    select distinct
                        ( a.c001 ) c001,
                        b.seq_id
                    from
                        htmldb_collections a,
                        (
                            select
                                min(seq_id) seq_id,
                                c001
                            from
                                htmldb_collections
                            where
                                collection_name = coll_name_in
                            group by
                                c001
                        )                  b
                    where
                            a.c001 = b.c001
                        and a.collection_name = coll_name_in
                    order by
                        c001 desc
                ) loop
                    htp.p('<row>');
                    htp.p('<null/>');
                    chart_values_out := chart_values_out || '<row>';
                    chart_values_out := chart_values_out || '<null/>';
                    for d in (
                        select
                            a.c002,
                            nvl(b.c003, 0) c003
                        from
                            (
                                select distinct
                                    ( a.c002 ) c002,
                                    b.seq_id
                                from
                                    htmldb_collections a,
                                    (
                                        select
                                            min(seq_id) seq_id,
                                            c002
                                        from
                                            htmldb_collections
                                        where
                                            collection_name = coll_name_in
                                        group by
                                            c002
                                    )                  b
                                where
                                        a.c002 = b.c002
                                    and a.collection_name = coll_name_in
                                order by
                                    b.seq_id
                            ) a,
                            (
                                select
                                    c002,
                                    c003
                                from
                                    htmldb_collections
                                where
                                        collection_name = coll_name_in
                                    and c001 = c.c001
                            ) b
                        where
                            a.c002 = b.c002 (+)
                        order by
                            a.seq_id
                    ) loop
                        begin
                            execute immediate 'BEGIN SELECT '
                                              || axis_val_conv_function
                                              || '('
                                              || d.c003
                                              || ') INTO xml_chart_pkg.v_value_axis_text '
                                              || 'FROM dual; EXCEPTION WHEN OTHERS THEN '
                                              || 'xml_chart_pkg.v_value_axis_text '
                                              || ':= ''Nn'';END;';
                        exception
                            when others then
                                xml_chart_pkg.v_value_axis_text := 'Nn';
                        end;

                        v_value_txt := xml_chart_pkg.v_value_axis_text;
                        chart_values_out := chart_values_out
                                            || '<string>'
                                            || v_value_txt
                                            || '</string>';
                        htp.p('<string>'
                              || v_value_txt
                              || '</string>');
                    end loop;

               /* This is end of the row data. */
                    htp.p('</row>');
                    chart_values_out := chart_values_out || '</row>';
                end loop;
            end if;

         /* This is end of the chart data. */
            htp.p('</chart_value_text>');
            chart_values_out := chart_values_out || '</chart_value_text>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*                                 PIE CHART                                            */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
        elsif chart_type_in in ( 'pie', '3d pie' ) then
            null;
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*                            FLOATING CHART                                            */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
        elsif chart_type_in in ( 'floating bar', 'floating column' ) then
            htp.p('<chart_value_text>');
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<chart_value_text>';
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c001
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                htp.p('<null/>');
                chart_values_out := chart_values_out || '<null/>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c002
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                begin
                    execute immediate 'BEGIN SELECT '
                                      || axis_val_conv_function
                                      || '('
                                      || c.c002
                                      || ') INTO xml_chart_pkg.v_value_axis_text '
                                      || 'FROM dual; EXCEPTION WHEN OTHERS THEN '
                                      || 'xml_chart_pkg.v_value_axis_text '
                                      || ':= ''Nn'';END;';
                exception
                    when others then
                        xml_chart_pkg.v_value_axis_text := 'Nn';
                end;

                v_value_txt := xml_chart_pkg.v_value_axis_text;
                htp.p('<string>'
                      || v_value_txt
                      || '</string>');
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || v_value_txt
                                    || '</string>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c003
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                begin
                    execute immediate 'BEGIN SELECT '
                                      || axis_val_conv_function
                                      || '('
                                      || c.c003
                                      || ') INTO xml_chart_pkg.v_value_axis_text '
                                      || 'FROM dual; EXCEPTION WHEN OTHERS THEN '
                                      || 'xml_chart_pkg.v_value_axis_text '
                                      || ':= ''Nn'';END;';
                exception
                    when others then
                        xml_chart_pkg.v_value_axis_text := 'Nn';
                end;

                v_value_txt := xml_chart_pkg.v_value_axis_text;
                htp.p('<string>'
                      || v_value_txt
                      || '</string>');
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || v_value_txt
                                    || '</string>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

         /* This is end of the chart data. */
            htp.p('</chart_value_text>');
            chart_values_out := chart_values_out || '</chart_value_text>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*                            CANDLESTICK CHART                                         */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
        elsif chart_type_in in ( 'candlestick' ) then
            htp.p('<chart_value_text>');
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<chart_value_text>';
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c001
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                htp.p('<null/>');
                chart_values_out := chart_values_out || '<null/>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c002
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                begin
                    execute immediate 'BEGIN SELECT '
                                      || axis_val_conv_function
                                      || '('
                                      || c.c002
                                      || ') INTO xml_chart_pkg.v_value_axis_text '
                                      || 'FROM dual; EXCEPTION WHEN OTHERS THEN '
                                      || 'xml_chart_pkg.v_value_axis_text '
                                      || ':= ''Nn'';END;';
                exception
                    when others then
                        xml_chart_pkg.v_value_axis_text := 'Nn';
                end;

                v_value_txt := xml_chart_pkg.v_value_axis_text;
                htp.p('<string>'
                      || v_value_txt
                      || '</string>');
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || v_value_txt
                                    || '</string>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c003
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                begin
                    execute immediate 'BEGIN SELECT '
                                      || axis_val_conv_function
                                      || '('
                                      || c.c003
                                      || ') INTO xml_chart_pkg.v_value_axis_text '
                                      || 'FROM dual; EXCEPTION WHEN OTHERS THEN '
                                      || 'xml_chart_pkg.v_value_axis_text '
                                      || ':= ''Nn'';END;';
                exception
                    when others then
                        xml_chart_pkg.v_value_axis_text := 'Nn';
                end;

                v_value_txt := xml_chart_pkg.v_value_axis_text;
                htp.p('<string>'
                      || v_value_txt
                      || '</string>');
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || v_value_txt
                                    || '</string>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c004
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                begin
                    execute immediate 'BEGIN SELECT '
                                      || axis_val_conv_function
                                      || '('
                                      || c.c004
                                      || ') INTO xml_chart_pkg.v_value_axis_text '
                                      || 'FROM dual; EXCEPTION WHEN OTHERS THEN '
                                      || 'xml_chart_pkg.v_value_axis_text '
                                      || ':= ''Nn'';END;';
                exception
                    when others then
                        xml_chart_pkg.v_value_axis_text := 'Nn';
                end;

                v_value_txt := xml_chart_pkg.v_value_axis_text;
                htp.p('<string>'
                      || v_value_txt
                      || '</string>');
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || v_value_txt
                                    || '</string>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select
                    c005
                from
                    htmldb_collections
                where
                    collection_name = coll_name_in
                order by
                    seq_id
            ) loop
                begin
                    execute immediate 'BEGIN SELECT '
                                      || axis_val_conv_function
                                      || '('
                                      || c.c005
                                      || ') INTO xml_chart_pkg.v_value_axis_text '
                                      || 'FROM dual; EXCEPTION WHEN OTHERS THEN '
                                      || 'xml_chart_pkg.v_value_axis_text '
                                      || ':= ''Nn'';END;';
                exception
                    when others then
                        xml_chart_pkg.v_value_axis_text := 'Nn';
                end;

                v_value_txt := xml_chart_pkg.v_value_axis_text;
                htp.p('<string>'
                      || v_value_txt
                      || '</string>');
                chart_values_out := chart_values_out
                                    || '<string>'
                                    || v_value_txt
                                    || '</string>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

         /* This is end of the chart data. */
            htp.p('</chart_value_text>');
            chart_values_out := chart_values_out || '</chart_value_text>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*                            SCATTER CHART                                             */
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
        elsif chart_type_in in ( 'scatter' ) then
            htp.p('<chart_value_text>');
            htp.p('<row>');
            htp.p('<null/>');
            chart_values_out := chart_values_out || '<chart_value_text>';
            chart_values_out := chart_values_out || '<row>';
            chart_values_out := chart_values_out || '<null/>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            select
                count(distinct c001)
            into scatter_series_counter
            from
                htmldb_collections
            where
                collection_name = coll_name_in;

            for i in 1..scatter_series_counter loop
                htp.p('<null/>');
                htp.p('<null/>');
                chart_values_out := chart_values_out || '<null/>';
                chart_values_out := chart_values_out || '<null/>';
            end loop;

            htp.p('</row>');
            chart_values_out := chart_values_out || '</row>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

            for c in (
                select distinct
                    ( a.c001 ) c001,
                    b.seq_id
                from
                    htmldb_collections a,
                    (
                        select
                            min(seq_id) seq_id,
                            c001
                        from
                            htmldb_collections
                        where
                            collection_name = coll_name_in
                        group by
                            c001
                    )                  b
                where
                        a.c001 = b.c001
                    and a.collection_name = coll_name_in
                order by
                    b.seq_id
            ) loop
                htp.p('<row>');
                htp.p('<null/>');
                chart_values_out := chart_values_out || '<row>';
                chart_values_out := chart_values_out || '<null/>';
                for d in (
                    select
                        c002,
                        c003
                    from
                        htmldb_collections
                    where
                            collection_name = coll_name_in
                        and c001 = c.c001
                    order by
                        seq_id
                ) loop
                    begin
                        execute immediate 'BEGIN SELECT '
                                          || axis_val_conv_function
                                          || '('
                                          || d.c002
                                          || ') INTO xml_chart_pkg.v_value_axis_text '
                                          || 'FROM dual; EXCEPTION WHEN OTHERS THEN '
                                          || 'xml_chart_pkg.v_value_axis_text '
                                          || ':= ''Nn'';END;';
                    exception
                        when others then
                            xml_chart_pkg.v_value_axis_text := 'Nn';
                    end;

                    v_value_txt := xml_chart_pkg.v_value_axis_text;
                    htp.p('<string>'
                          || v_value_txt
                          || '</string>');
                    chart_values_out := chart_values_out
                                        || '<string>'
                                        || v_value_txt
                                        || '</string>';
                    begin
                        execute immediate 'BEGIN SELECT '
                                          || axis_val_conv_function
                                          || '('
                                          || d.c003
                                          || ') INTO xml_chart_pkg.v_value_axis_text '
                                          || 'FROM dual; EXCEPTION WHEN OTHERS THEN '
                                          || 'xml_chart_pkg.v_value_axis_text '
                                          || ':= ''Nn'';END;';
                    exception
                        when others then
                            xml_chart_pkg.v_value_axis_text := 'Nn';
                    end;

                    v_value_txt := xml_chart_pkg.v_value_axis_text;
                    htp.p('<string>'
                          || v_value_txt
                          || '</string>');
                    chart_values_out := chart_values_out
                                        || '<string>'
                                        || v_value_txt
                                        || '</string>';
                end loop;

            /* This is end of the row data. */
                htp.p('</row>');
                chart_values_out := chart_values_out || '</row>';
                if debug_xml_in = 'Y' then
                    xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                    chart_values_out := null;
                end if;

            end loop;

         /* This is end of the chart data. */
            htp.p('</chart_value_text>');
            chart_values_out := chart_values_out || '</chart_value_text>';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_values_out, xml_filename_in, xml_output_dir_name_in);
                chart_values_out := null;
            end if;

        end if;

    exception
        when others then
            v_error := sqlerrm;
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(v_error, xml_filename_in, xml_output_dir_name_in);
                xml_chart_pkg.delete_coll_pr(coll_name_in);
            end if;

            xml_chart_pkg.delete_coll_pr(coll_name_in);
    end axis_values_xml_pr;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    procedure chart_settings_xml_pr (
        chart_type_in          in varchar2,
        debug_xml_in           in varchar2,
        xml_filename_in        in varchar2,
        xml_output_dir_name_in in varchar2
    ) is
        v_htp_p varchar2(32767) default '';
        v_loops integer;
        v_error varchar2(4000);
    begin
        for c in (
            select distinct
                ( cat_name ) cat_name
            from
                xml_chart_settings
            where
                instr(':'
                      || chart_type
                      || ':', ':'
                              || chart_type_in
                              || ':') > 0
        ) loop
            v_htp_p := '<' || c.cat_name;
            for d in (
                select
                    setting_name,
                    setting_value
                from
                    xml_chart_settings
                where
                        cat_name = c.cat_name
                    and instr(':'
                              || chart_type
                              || ':', ':'
                                      || chart_type_in
                                      || ':') > 0
            ) loop
                v_htp_p := v_htp_p
                           || ' '
                           || d.setting_name
                           || '='
                           || '"'
                           || d.setting_value
                           || '"';
            end loop;

            v_htp_p := v_htp_p || '/> ';
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(v_htp_p, xml_filename_in, xml_output_dir_name_in);
            end if;

            htp.p(v_htp_p);
        end loop;
    exception
        when others then
            if debug_xml_in = 'Y' then
                v_error := sqlerrm;
                xml_chart_pkg.create_xml_file_pr(v_error, xml_filename_in, xml_output_dir_name_in);
            end if;
    end chart_settings_xml_pr;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    procedure create_xml_file_pr (
        chart_xml_text_in      in varchar2,
        xml_filename_in        in varchar2,
        xml_output_dir_name_in in varchar2
    ) is
        v_utl varchar2(32767);
    begin
        v_utl := 'DECLARE '
                 || 'xml_file     UTL_FILE.file_type;'
                 || 'BEGIN '
                 || 'xml_file := '
                 || 'UTL_FILE.fopen (UPPER ('''
                 || xml_output_dir_name_in
                 || '''), '''
                 || xml_filename_in
                 || ''', ''A'');'
                 || 'UTL_FILE.put_line (xml_file, '''
                 || chart_xml_text_in
                 || ''');'
                 || 'UTL_FILE.fclose (xml_file'
                 || ');'
                 || 'END;';

        execute immediate v_utl;
    exception
        when others then
            null;
    end create_xml_file_pr;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    procedure read_xml_file_pr (
        directory_in in varchar2,
        file_in      in varchar2
    ) as

        lob_loc  bfile default bfilename(
            upper(directory_in),
            file_in
        );
        v_mime   varchar2(48) default 'application/xml';
        v_length number;
    begin
        v_length := dbms_lob.getlength(lob_loc);
      --
      -- set up HTTP header
      --
            -- use an NVL around the mime type and
            -- if it is a null set it to application/octect
            -- application/octect may launch a download window from windows
        owa_util.mime_header(
            nvl(v_mime, 'application/octet'),
            false
        );
      -- set the size so the browser knows how much to download
        htp.p('Content-length: ' || v_length);
      -- the filename will be used by the browser if the users does a save as
        htp.p('Content-Disposition:  attachment; filename="'
              || substr(file_in,
                        instr(file_in, '/') + 1)
              || '"');
      -- close the headers
        owa_util.http_header_close;
      -- download the BLOB
        wpg_docload.download_file(lob_loc);
    end read_xml_file_pr;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    procedure chart_licence_pr is
    begin
      /* This is the licence code. */
        htp.p('<license>H1XQC9CUU7.L.NS5T4Q79KLYCK07EK</license>');
    end chart_licence_pr;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    function chart_types_fn
      /* Optionally, a delimiter could be defined as a parameter. */ return chart_table_type is

        p_string_in    varchar2(400) := 'line, column, stacked column, '
                                     || 'floating column, 3d column, stacked 3d column, '
                                     || 'parallel 3d column, pie, '
                                     || '3d pie, bar, stacked bar, floating bar, area, '
                                     || 'stacked area, candlestick, scatter, polar';
        p_delimiter_in varchar2(1) := ',';
        v_string       long default p_string_in || nvl(p_delimiter_in, ',');
        v_data         chart_table_type := chart_table_type();
        v_num          number;
    begin
        loop
            exit when v_string is null;
            v_num := instr(v_string,
                           nvl(p_delimiter_in, ','));
            v_data.extend;
            v_data(v_data.count) := ltrim(rtrim(substr(v_string, 1, v_num - 1)));

            v_string := substr(v_string, v_num + 1);
        end loop;

        return v_data;
    exception
        when others then
            return null;
    end chart_types_fn;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    function chart_templ_string_to_table_fn (
        p_string_in    in varchar2 default null,
        p_delimiter_in in varchar2 default ','
    ) return chart_table_type is
        v_string long default p_string_in || p_delimiter_in;
        v_data   chart_table_type := chart_table_type();
        v_num    number;
    begin
        loop
            exit when v_string is null;
            v_num := instr(v_string, p_delimiter_in);
            v_data.extend;
            v_data(v_data.count) := ltrim(rtrim(substr(v_string, 1, v_num - 1)));

            v_string := substr(v_string, v_num + 1);
        end loop;

        return v_data;
    exception
        when others then
            return null;
    end chart_templ_string_to_table_fn;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    function chart_types_val_fn (
        chart_type_in in varchar2
    ) return boolean is
        v_chart_type_valid varchar2(50);
    begin
        for c in (
            select
                column_value col_val
            from
                table ( xml_chart_pkg.chart_types_fn )
            where
                column_value = chart_type_in
        ) loop
            v_chart_type_valid := c.col_val;
        end loop;

        if v_chart_type_valid is not null then
            return true;
        else
            return false;
        end if;
    end chart_types_val_fn;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    function check_directory_fn (
        xml_output_dir_name_in in varchar2
    ) return boolean is

        cursor check_dir is
        select
            directory_name
        from
            all_directories
        where
            directory_name = upper(xml_output_dir_name_in);

        v_directory varchar2(32);
    begin
        for c in check_dir loop
            v_directory := c.directory_name;
        end loop;
        if v_directory is not null then
            return true;
        else
            return false;
        end if;
    end check_directory_fn;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    function get_chart_plsql return varchar2 is
        chart_plsql varchar2(4000);
    begin
        chart_plsql := 'BEGIN '
                       || chr(10)
                       || 'xml_chart_pkg.xml_chart_pr ( '
                       || chr(10)
                       || 'item_for_query             =>  :P1_ITEM, '
                       || chr(10)
                       || '--item storing your chart query'
                       || chr(10)
                       || 'chart_type_in              => ''stacked column'', '
                       || chr(10)
                       || '--your chart type'
                       || chr(10)
                       || 'sort_series_in             => ''ASC'', '
                       || chr(10)
                       || '--how to sort series'
                       || chr(10)
                       || 'width_in                   =>  600, '
                       || chr(10)
                       || '--width of your region'
                       || chr(10)
                       || 'height_in                  =>  450, '
                       || chr(10)
                       || '--height of your region'
                       || chr(10)
                       || 'debug_xml_in               => ''N'', '
                       || chr(10)
                       || '--using debug option'
                       || chr(10)
                       || 'xml_output_dir_name_in     => ''DIRECTORY'', '
                       || chr(10)
                       || '--debug output directory'
                       || chr(10)
                       || 'chart_template_in          => ''MY_TEMPLATE,SWITCH_COLORS'', '
                       || chr(10)
                       || '--templates to be used with your chart'
                       || chr(10)
                       || 'chart_standard_ignore_in   => ''N'', '
                       || chr(10)
                       || '--ignore all standard settings'
                       || chr(10)
                       || 'link_type_in               => ''P'', '
                       || chr(10)
                       || '--link type P for popup and R for redirect'
                       || chr(10)
                       || 'page_to_pass_values_to     => ''200'', '
                       || chr(10)
                       || '--page to pass values in the link'
                       || chr(10)
                       || 'request_in                 => ''SORT'', '
                       || chr(10)
                       || '--request to pass within link'
                       || chr(10)
                       || 'items_to_pass_values_to    => ''P200_ITEM'', '
                       || chr(10)
                       || '--items to pass values to, comma delimited'
                       || chr(10)
                       || 'values_to_pass_to_items    => ''_category_'', '
                       || chr(10)
                       || '--values to pass to items, see XML reference'
                       || chr(10)
                       || 'link_pop_up_w_in           => ''1000'', '
                       || chr(10)
                       || '--link popup window width'
                       || chr(10)
                       || 'link_pop_up_h_in           => ''800'', '
                       || chr(10)
                       || '--link popup window height'
                       || chr(10)
                       || 'chart_background_color_in  => ''#ededd6'', '
                       || chr(10)
                       || '--region color'
                       || chr(10)
                       || 'unique_id_in               =>  NULL, '
                       || chr(10)
                       || '--unique string to identify your chart if the same chart '
                       || chr(10)
                       || '--type is used on the same page'
                       || chr(10)
                       || 'turn_caching_on            => ''N'', '
                       || chr(10)
                       || '--if your want to keep the session result per chart, '
                       || chr(10)
                       || '--use collection to store the result set'
                       || chr(10)
                       || 'default_directory_xml      => ''/i/'', '
                       || chr(10)
                       || '--if your want to specifiy another directory, '
                       || chr(10)
                       || '--you need to determine this parameter'
                       || chr(10)
                       || 'axis_val_conv_function     => NULL,'
                       || chr(10)
                       || '--if your want to convert axis values '
                       || 'x_axis_title               => NULL,'
                       || chr(10)
                       || '--title of the x axis '
                       || 'y_axis_title               => NULL'
                       || chr(10)
                       || '--title of the y axis '
                       || '); '
                       || chr(10)
                       || 'END;';

        return chart_plsql;
    end get_chart_plsql;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    procedure chart_region_pr (
        app_user_in              in varchar2,
        app_id_in                in varchar2,
        session_id_in            in varchar2,
        ssg_id_in                in varchar2,
        page_id_in               in varchar2,
        coll_name_in             in varchar2,
        chart_type_in            in varchar2,
        width_in                 in number,
        height_in                in number,
        debug_xml_in             in varchar2,
        xml_output_dir_name_in   in varchar2,
        chart_template_in        in varchar2,
        chart_standard_ignore_in in varchar2,
        link_type_in             in varchar2,
        chart_link_in            in varchar2,
        link_pop_up_w_in         in number,
        link_pop_up_h_in         in number,
        sort_series_in           in varchar2,
        turn_caching_on_in       in varchar2,
        axis_val_conv_function   in varchar2,
        x_axis_title             in varchar2,
        y_axis_title             in varchar2
    ) is

        xml_filename       varchar2(200);
        chart_link_to_pass varchar2(400);
        chart_rect_w       number;
        chart_rect_h       number;
        debug_link         varchar2(400);
        debug_chart_rect_h number;
        debug_link_x       number;
        debug_link_y       number;
        x_title_pos        number;
        y_title_pos        number;
    begin
      /* Session Start */
        chart_rect_w := round(width_in -(100), 0);
        chart_rect_h := round(height_in -(170), 0);
        debug_chart_rect_h := round(height_in -(height_in * 0.47), 0);
        debug_link_x := 1;
        debug_link_y := height_in - 20;
        x_title_pos := round((width_in / 2.05) -(length(x_axis_title) * 2),
                             0);

        y_title_pos := round(height_in * 0.55 + length(y_axis_title) * 2,
                             0);

        if debug_xml_in = 'Y' then
            xml_filename := 'chart_debug_'
                            || app_id_in
                            || '_'
                            || page_id_in
                            || '_'
                            || upper(replace(chart_type_in, ' ', '_'))
                            || '_'
                            || to_char(sysdate, 'DDMMYYYYHH24MISS')
                            || '.xml';
        end if;

      /* This part is generating the chart attributes. */
        htp.p('<?xml version="1.0" encoding="UTF-8"?>');
        htp.p('<chart>');

      /* This is the chart type property (stacked, bar...) */
        htp.p('<chart_type>'
              || chart_type_in
              || '</chart_type>');
        if debug_xml_in = 'Y' then
            xml_chart_pkg.create_xml_file_pr('<?xml version="1.0" encoding="UTF-8"?>'
                                             || '<chart>'
                                             || '<chart_type>'
                                             || chart_type_in
                                             || '</chart_type>', xml_filename, xml_output_dir_name_in);
        end if;

      /* Get the XML settings from the standard table. */
        if chart_standard_ignore_in like 'N' then
            xml_chart_pkg.chart_settings_xml_pr(chart_type_in, debug_xml_in, xml_filename, xml_output_dir_name_in);
        end if;

      /* Determine the chart rectangle based on the region
         widht / height. If chart rectangle specified in
         the template, this setting will be ignored. */
        htp.p('<chart_rect width="'
              || chart_rect_w
              || '" '
              || 'height="'
              || chart_rect_h
              || '" />');

        if debug_xml_in = 'Y' then
            xml_chart_pkg.create_xml_file_pr('<chart_rect width="'
                                             || chart_rect_w
                                             || '" '
                                             || 'height="'
                                             || chart_rect_h
                                             || '" />', xml_filename, xml_output_dir_name_in);
        end if;

      /* Use Templates. Teplates will overwrite the standard
        settings if used. */
        for c in (
            select
                template_text
            from
                xml_chart_templates
            where
                lower(template_name) in (
                    select
                        lower(column_value) template_name
                    from
                        table ( xml_chart_pkg.chart_templ_string_to_table_fn(chart_template_in) )
                )
        ) loop
            htp.p(c.template_text);
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(c.template_text, xml_filename, xml_output_dir_name_in);
            end if;

        end loop;

        wwv_flow_api.set_security_group_id(ssg_id_in);
      /* Get the chart XML data. */
        xml_chart_pkg.chart_values_xml_pr(app_user_in, app_id_in, session_id_in, page_id_in, coll_name_in,
                                          chart_type_in, debug_xml_in, xml_filename, xml_output_dir_name_in, sort_series_in,
                                          turn_caching_on_in);

      /* Get the chart axis text. */
        if function_exists(axis_val_conv_function) then
            xml_chart_pkg.axis_values_xml_pr(app_user_in, app_id_in, session_id_in, page_id_in, coll_name_in,
                                             chart_type_in, debug_xml_in, xml_filename, xml_output_dir_name_in, sort_series_in,
                                             turn_caching_on_in, axis_val_conv_function);
        end if;

       /* This is the link. To pass the click-variables to the
      javascript function, any occurrences of _col_, _row_,
      _value_, _category_, and _series_ in the URL are replaced
      with the actual values */
        if chart_link_in is not null then
            chart_link_to_pass := '<link_data url="javascript:'
                                  ||
                case
                    when upper(link_type_in) = 'P' then
                        'popUp2'
                    else 'redirect'
                end
                                  || '(''f?p='
                                  || replace(chart_link_in, ';', ':')
                                  || ''', '
                                  || link_pop_up_w_in
                                  || ','
                                  || link_pop_up_h_in
                                  || ');" target="javascript" />';

            htp.p(chart_link_to_pass);
            if debug_xml_in = 'Y' then
                xml_chart_pkg.create_xml_file_pr(chart_link_to_pass, xml_filename, xml_output_dir_name_in);
            end if;

        end if;

        if x_axis_title is not null or y_axis_title is not null
                                       and chart_type_in not in ( 'pie', '3d pie' ) then
            htp.p('<draw> <text transition="dissolve" DELAY="0" duration="0" '
                  || 'color="000000" alpha="90" font="arial" rotation="-90" '
                  || 'bold="true" SIZE="12" x="5" y="'
                  || y_title_pos
                  || '" width="200" height="100" '
                  || 'h_align="left" v_align="top">'
                  || y_axis_title
                  || '</text> <text '
                  || 'transition="dissolve" DELAY="0" duration="0" color="000000" '
                  || 'alpha="90" font="arial" rotation="0" bold="true" SIZE="12" '
                  || 'x="'
                  || x_title_pos
                  || '" y="'
                  || round(height_in * 0.95 - 10, 0)
                  || '" width="200" height="50" h_align="left" '
                  || 'v_align="top">'
                  || x_axis_title
                  || '</text> </draw>');
        end if;

      /* This is where the debugging download link is created.
         The tags <draw></draw> are used to create this link.
         Any other <draw> tags used in a template will be
         overwritten by this one. */
        if debug_xml_in = 'Y' then
            debug_link := '<chart_rect height="'
                          || debug_chart_rect_h
                          || '" /> '
                          || '<draw> <text x="'
                          || debug_link_x
                          || '" y="'
                          || debug_link_y
                          || '" size="12" color="FF0000">debug</text> </draw> '
                          || '<link>'
                          || '<area x="'
                          || debug_link_x
                          || '" '
                          || 'y="'
                          || debug_link_y
                          || '" '
                          || 'width="75"  '
                          || 'height="25" '
                          || 'url="xml_chart_pkg.read_xml_file_pr?directory_in='
                          || xml_output_dir_name_in
                          || '='
                          || xml_filename
                          || '" '
                          || 'target="_blank" '
                          || '/> '
                          || '</link>';

            htp.p(debug_link);
            xml_chart_pkg.create_xml_file_pr(
                replace(debug_link, '&', '?'),
                xml_filename,
                xml_output_dir_name_in
            );
        end if;

      /* Get the chart licence. */
        xml_chart_pkg.chart_licence_pr;
      /* This is end of the chart. */
        htp.p('</chart>');
        if debug_xml_in = 'Y' then
            xml_chart_pkg.create_xml_file_pr('</chart>', xml_filename, xml_output_dir_name_in);
        end if;

        if turn_caching_on_in = 'N' then
            htmldb_custom_auth.define_user_session(app_user_in, session_id_in);
            htmldb_application.g_flow_id := app_id_in;
            htmldb_custom_auth.post_login(app_user_in, session_id_in, app_id_in
                                                                      || ':'
                                                                      || page_id_in);
            xml_chart_pkg.delete_coll_pr(coll_name_in);
        end if;

    exception
        when others then
            xml_chart_pkg.delete_coll_pr(coll_name_in);
    end chart_region_pr;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    procedure call_chart_region_pr (
        coll_name_in              in varchar2,
        chart_type_in             in varchar2,
        sort_series_in            in varchar2,
        width_in                  in number,
        height_in                 in number,
        debug_link                in varchar2,
        chart_template            in varchar2,
        chart_standard_ignore_in  in varchar2,
        chart_link                in varchar2,
        link_type_in              in varchar2,
        link_pop_up_w             in varchar2,
        link_pop_up_h             in varchar2,
        chart_background_color_in in varchar2,
        unique_id_in              in varchar2,
        turn_caching_on           in varchar2,
        app_user_in               in varchar2,
        app_id_in                 in varchar2,
        session_id_in             in varchar2,
        ssg_id_in                 in varchar2,
        page_id_in                in varchar2,
        default_directory_xml     in varchar2,
        axis_val_conv_function    in varchar2,
        x_axis_title              in varchar2,
        y_axis_title              in varchar2
    ) is
    begin
      /* Call Chart_Region_Pr. */
        htp.p('<OBJECT classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"');
        htp.p('codebase="https://download.macromedia.com/pub/shockwave/cabs/flash/' || 'swflash.cab#version=6,0,0,0"');
        htp.p('WIDTH="'
              || width_in
              || '"');
        htp.p('HEIGHT="'
              || height_in
              || '"');
        htp.p('ID="charts"');
        htp.p('ALIGN="">');
        htp.p('<PARAM NAME=movie VALUE="'
              || default_directory_xml
              || 'charts.swf?library_path='
              || default_directory_xml
              || 'charts_library='
              || 'xml_chart_pkg.chart_region_pr?'
              || 'app_user_in='
              || app_user_in
              || '%26app_id_in='
              || app_id_in
              || '%26session_id_in='
              || session_id_in
              || '%26ssg_id_in='
              || ssg_id_in
              || '%26page_id_in='
              || page_id_in
              || '%26coll_name_in='
              || coll_name_in
              || '%26chart_type_in='
              || chart_type_in
              || '%26width_in='
              || width_in
              || '%26height_in='
              || height_in
              || debug_link
              || chart_template
              || chart_standard_ignore_in
              || chart_link
              || '%26link_type_in='
              || link_type_in
              || link_pop_up_w
              || link_pop_up_h
              || '%26sort_series_in='
              || sort_series_in
              || '%26turn_caching_on_in='
              || turn_caching_on
              || '%26axis_val_conv_function='
              || axis_val_conv_function
              || '%26x_axis_title='
              || x_axis_title
              || '%26y_axis_title='
              || y_axis_title
              || '">');

        htp.p('<PARAM NAME=quality VALUE=high>');
        htp.p('<PARAM NAME=bgcolor VALUE='
              || chart_background_color_in
              || '>');
        htp.p('<EMBED src="'
              || default_directory_xml
              || 'charts.swf?library_path='
              || default_directory_xml
              || 'charts_library='
              || 'xml_chart_pkg.chart_region_pr?'
              || 'app_user_in='
              || app_user_in
              || '%26app_id_in='
              || app_id_in
              || '%26session_id_in='
              || session_id_in
              || '%26ssg_id_in='
              || ssg_id_in
              || '%26page_id_in='
              || page_id_in
              || '%26coll_name_in='
              || coll_name_in
              || '%26chart_type_in='
              || chart_type_in
              || '%26width_in='
              || width_in
              || '%26height_in='
              || height_in
              || debug_link
              || chart_template
              || chart_standard_ignore_in
              || chart_link
              || '%26link_type_in='
              || link_type_in
              || link_pop_up_w
              || link_pop_up_h
              || '%26sort_series_in='
              || sort_series_in
              || '%26turn_caching_on_in='
              || turn_caching_on
              || '%26axis_val_conv_function='
              || axis_val_conv_function
              || '%26x_axis_title='
              || x_axis_title
              || '%26y_axis_title='
              || y_axis_title
              || '"');

        htp.p('quality=high');
        htp.p('bgcolor=' || chart_background_color_in);
        htp.p('WIDTH="'
              || width_in
              || '"');
        htp.p('HEIGHT="'
              || height_in
              || '"');
        htp.p('NAME="charts"');
        htp.p('ALIGN=""');
        htp.p('swLiveConnect="true"');
        htp.p('TYPE="application/x-shockwave-flash"');
        htp.p('PLUGINSPAGE="https://www.macromedia.com/go/getflashplayer">');
        htp.p('</EMBED>');
        htp.p('</OBJECT>');
    end call_chart_region_pr;

/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
    procedure xml_chart_pr (
        item_for_query            in varchar2,
        chart_type_in             in varchar2 default 'stacked column',
        sort_series_in            in varchar2 default 'ASC',
        width_in                  in number default 600,
        height_in                 in number default 450,
        debug_xml_in              in varchar2 default 'N',
        xml_output_dir_name_in    in varchar2 default 'DIRECTORY',
        chart_template_in         in varchar2 default null,
        chart_standard_ignore_in  in varchar2 default 'N',
        link_type_in              in varchar2 default 'P',
        page_to_pass_values_to    in number default null,
        request_in                in varchar2 default null,
        items_to_pass_values_to   in varchar2 default null,
        values_to_pass_to_items   in varchar2 default null,
        link_pop_up_w_in          in number default 1100,
        link_pop_up_h_in          in number default 800,
        chart_background_color_in in varchar2 default '#ededd6',
        unique_id_in              in varchar2 default null,
        turn_caching_on           in varchar2 default 'N',
        default_directory_xml     in varchar2 default '/i/',
        axis_val_conv_function    in varchar2 default null,
        x_axis_title              in varchar2 default null,
        y_axis_title              in varchar2 default null
    ) is

        app_user_in              varchar2(50) default v('APP_USER');
        app_id_in                varchar2(10) default v('APP_ID');
        session_id_in            varchar2(20) default v('APP_SESSION');
        page_id_in               varchar2(10) default v('APP_PAGE_ID');
        ssg_id_in                varchar2(50) default htmldb_application.get_current_flow_sgid(v('APP_ID'));
        chart_type_error exception;
        pie_chart_series         number;
        pie_chart_total          number;
        pie_chart_error exception;
        float_chart_series       number;
        float_chart_error exception;
        candlestick_chart_series number;
        candlestick_chart_error exception;
        scatter_chart_total      number;
        scatter_chart_error exception;
        directory_not_exists exception;
        query_item_null exception;
        delete_collection exception;
        parameter_out_of_range exception;
        function_error exception;
        debug_link               varchar2(200);
        chart_template           varchar2(100);
        chart_standard_ignore    varchar2(50);
        chart_link               varchar2(100);
        link_pop_up_w            varchar2(50);
        link_pop_up_h            varchar2(50);
        v_series                 varchar2(50);
        v_categories             varchar2(50);
        chart_query              varchar2(32767);
        coll_name                varchar2(250);
        v_error                  varchar2(4000);
        v_code                   varchar2(4000);
        v_conv_function          varchar2(30);
        dir_xml                  varchar2(200);
    begin
        if upper(sort_series_in) not in ( 'ASC', 'DESC' )
           or upper(debug_xml_in) not in ( 'N', 'Y' )
        or upper(chart_standard_ignore_in) not in ( 'N', 'Y' )
        or upper(link_type_in) not in ( 'P', 'R' )
        or upper(turn_caching_on) not in ( 'N', 'Y' ) then
            raise parameter_out_of_range;
        end if;

        dir_xml := rtrim(default_directory_xml, '/')
                   || '/';
        if
            axis_val_conv_function is not null
            and not function_exists(axis_val_conv_function)
        then
            raise function_error;
        end if;
        execute immediate 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''';
        chart_query := item_for_query;
        if chart_query is null then
            raise query_item_null;
        end if;
        coll_name := replace('C'
                             || unique_id_in
                             || upper(chart_type_in)
                             || session_id_in
                             || app_id_in
                             || page_id_in,
                             ' ',
                             '');

        xml_chart_pkg.delete_coll_pr(coll_name);
        htmldb_collection.create_collection_from_query_b(
            p_collection_name => coll_name,
            p_query           => chart_query
        );
        chart_link := '%26chart_link_in='
                      || app_id_in
                      || ';'
                      || page_to_pass_values_to
                      || ';'
                      || session_id_in
                      || ';'
                      || request_in
                      || ';;;'
                      || replace(items_to_pass_values_to, ':', '')
                      || ';'
                      || values_to_pass_to_items;

        link_pop_up_w := '%26link_pop_up_w_in=' || link_pop_up_w_in;
        link_pop_up_h := '%26link_pop_up_h_in=' || link_pop_up_h_in;
        if debug_xml_in = 'Y' then
            if not check_directory_fn(xml_output_dir_name_in) then
                raise directory_not_exists;
            end if;
        end if;

        debug_link := '%26debug_xml_in='
                      || debug_xml_in
                      || '%26xml_output_dir_name_in='
                      || xml_output_dir_name_in;
        chart_template := '%26chart_template_in=' || nvl(chart_template_in, 'NO_TEMPLATE');
        chart_standard_ignore := '%26chart_standard_ignore_in=' || chart_standard_ignore_in;

      /* Check if the pie chart second column is number. */
        if chart_type_in in ( 'pie', '3d pie' ) then
            for c in (
                select
                    c002
                from
                    htmldb_collections
                where
                    collection_name = coll_name
            ) loop
                if not xml_chart_pkg.to_number_fn(c.c002) then
                    raise pie_chart_error;
                end if;
            end loop;
      /* Check if the floating chart second and third column is
         number and second column is bigger than third column. */
        elsif chart_type_in in ( 'floating bar', 'floating column' ) then
            for c in (
                select
                    c002,
                    c003
                from
                    htmldb_collections
                where
                    collection_name = coll_name
            ) loop
                if not xml_chart_pkg.to_number_fn(c.c002)
                or not xml_chart_pkg.to_number_fn(c.c003)
                or to_number ( c.c002 ) <= to_number ( c.c003 ) then
                    raise float_chart_error;
                end if;
            end loop;
      /* Check if the candlestick chart second to fifth column
         is number, second column is bigger than third column,
        fourth column is bigger equal third and fifth column
        is smaller equal to the second column. */
        elsif chart_type_in in ( 'candlestick' ) then
            for c in (
                select
                    c002,
                    c003,
                    c004,
                    c005
                from
                    htmldb_collections
                where
                    collection_name = coll_name
            ) loop
                if not xml_chart_pkg.to_number_fn(c.c002)
                or not xml_chart_pkg.to_number_fn(c.c003)
                or not xml_chart_pkg.to_number_fn(c.c004)
                or not xml_chart_pkg.to_number_fn(c.c005)
                or to_number ( c.c002 ) <= to_number ( c.c003 )
                or to_number ( c.c004 ) < to_number ( c.c003 )
                or to_number ( c.c005 ) > to_number ( c.c002 ) then
                    raise candlestick_chart_error;
                end if;
            end loop;
      /* Check if the scatter chart second and third column is
         number and second column is bigger than third column. */
        elsif chart_type_in in ( 'scatter' ) then
            for c in (
                select
                    c002,
                    c003
                from
                    htmldb_collections
                where
                    collection_name = coll_name
            ) loop
                if not xml_chart_pkg.to_number_fn(c.c002)
                or not xml_chart_pkg.to_number_fn(c.c003) then
                    raise scatter_chart_error;
                end if;
            end loop;
      /* Check if the chart type is properly defined. */
        elsif not chart_types_val_fn(chart_type_in) then
            raise chart_type_error;
        end if;

      /* Call Chart Procedure. */
        xml_chart_pkg.call_chart_region_pr(coll_name, chart_type_in, sort_series_in, width_in, height_in,
                                           debug_link, chart_template, chart_standard_ignore, chart_link, link_type_in,
                                           link_pop_up_w, link_pop_up_h, chart_background_color_in, unique_id_in, turn_caching_on,
                                           app_user_in, app_id_in, session_id_in, ssg_id_in, page_id_in,
                                           dir_xml, axis_val_conv_function, x_axis_title, y_axis_title);

    exception
        when pie_chart_error then
            raise_application_error(-20001, '</br>'
                                            || 'Your query doesn''t match the PIE chart requirements!'
                                            || '</br>'
                                            || 'Your query probably returns more then one row per'
                                            || '</br>'
                                            || 'series. Please correct the query or change the type'
                                            || '</br>'
                                            || 'of the chart!');

            xml_chart_pkg.delete_coll_pr(coll_name);
        when float_chart_error then
            raise_application_error(-20001, '</br>'
                                            || 'Your query doesn''t match the FLOATING chart requirements!'
                                            || '</br>'
                                            || 'Your query probably returns more then two rows per series.'
                                            || '</br>'
                                            || 'Please correct the query or change the type of the chart!');

            xml_chart_pkg.delete_coll_pr(coll_name);
        when candlestick_chart_error then
            raise_application_error(-20001, '</br>'
                                            || 'Your query doesn''t match the CANDLESTICK chart requirements!'
                                            || '</br>'
                                            || 'Your query hast to return four (4) rows per series. Please correct '
                                            || '</br>'
                                            || 'the query or change the type of the chart!');

            xml_chart_pkg.delete_coll_pr(coll_name);
        when scatter_chart_error then
            raise_application_error(-20001, '</br>'
                                            || 'Your query doesn''t match the SCATTER chart requirements!'
                                            || '</br>'
                                            || 'Your query hast to return PAIRS OF COLUMNS per series. Please '
                                            || '</br>'
                                            || 'correct the query or change the type of the chart!');

            xml_chart_pkg.delete_coll_pr(coll_name);
        when chart_type_error then
            raise_application_error(-20001, '</br>'
                                            || 'Your have selected an invalid chart type!'
                                            || '</br>'
                                            || 'Please change the type of the chart!');
            xml_chart_pkg.delete_coll_pr(coll_name);
        when directory_not_exists then
            raise_application_error(-20001, '</br>'
                                            || 'The directory you specified doesn''t exist!'
                                            || '</br>'
                                            || 'Please specify a right directory.'
                                            || '</br>');

            xml_chart_pkg.delete_coll_pr(coll_name);
        when query_item_null then
            raise_application_error(-20001, '</br>'
                                            || 'The item specified in the package doesn''t contain a query!'
                                            || '</br>'
                                            || 'Please specify a right query and try again.'
                                            || '</br>');

            xml_chart_pkg.delete_coll_pr(coll_name);
        when parameter_out_of_range then
            raise_application_error(-20001, '</br>'
                                            || 'One of the following parameters is out of range:'
                                            || '</br>'
                                            || 'sort_series_in (''ASC'', ''DESC'')'
                                            || '</br>'
                                            || 'debug_xml_in  (''N'', ''Y'')'
                                            || '</br>'
                                            || 'chart_standard_ignore_in  (''N'', ''Y'')'
                                            || '</br>'
                                            || 'link_type_in  (''P'', ''R'')'
                                            || '</br>'
                                            || 'turn_caching_on  (''N'', ''Y'')'
                                            || '</br>'
                                            || 'Please specify a right range.'
                                            || '</br>');

            xml_chart_pkg.delete_coll_pr(coll_name);
        when function_error then
            raise_application_error(-20001, '</br>'
                                            || 'Your function is either invalid or it doesn''t exist!'
                                            || '</br>'
                                            || 'Please specify the right function.'
                                            || '</br>');

            xml_chart_pkg.delete_coll_pr(coll_name);
        when others then
            v_error := sqlerrm;
            v_code := sqlcode;
            raise_application_error(-20001, '</br>'
                                            || 'Your query is invalid!'
                                            || '</br>'
                                            || 'SQL_ERROR: '
                                            || v_error
                                            || '</br>'
                                            || 'SQL_CODE: '
                                            || v_code
                                            || '</br>'
                                            || 'Please correct and try again.'
                                            || '</br>');

            xml_chart_pkg.delete_coll_pr(coll_name);
    end xml_chart_pr;
/*****************************************************************************************/
/*****************************************************************************************/
/*****************************************************************************************/
end xml_chart_pkg;
/


-- sqlcl_snapshot {"hash":"404c97655db3472892594d2730828e2542c88469","type":"PACKAGE_BODY","name":"XML_CHART_PKG","schemaName":"SAMQA","sxml":""}