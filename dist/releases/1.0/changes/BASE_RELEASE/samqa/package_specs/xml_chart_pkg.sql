-- liquibase formatted sql
-- changeset SAMQA:1754374142511 stripComments:false logicalFilePath:BASE_RELEASE\samqa\package_specs\xml_chart_pkg.sql runAlways:false runOnChange:false replaceIfExists:true failOnError:true
-- sqlcl_snapshot src/database/samqa/package_specs/xml_chart_pkg.sql:null:6fc22d52d698bfa5ac056c9758ad0a03b7975e48:create

create or replace package samqa.xml_chart_pkg as
/*********************************************************************************/
/*
   NAME:       XML_Chart_Pkg
   PURPOSE:    PACKAGE FOR generating XML Charts

   REVISIONS:
   Ver        DATE        Author            Description
   ---------  ----------  ---------------   -----------------------------------
   1.4        19.02.2007  D. Kubicek        Extended Version. Works with 3.0
                                                                                 */
/*********************************************************************************/
/*
   REQUIERMENTS:
   ----------------------------------------------------------------------------
      See Readme.pdf for further details.
*/
/*********************************************************************************/
    v_value_axis_text varchar2(200);

/*********************************************************************************/
    function function_exists (
        function_name in varchar2
    ) return boolean;

/*********************************************************************************/
    procedure delete_coll_pr (
        coll_name_in varchar2
    );

/*********************************************************************************/
    function to_number_fn (
        value_in varchar2
    ) return boolean;

/*********************************************************************************/
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
    );

/*********************************************************************************/
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
    );

/*********************************************************************************/
    procedure chart_settings_xml_pr (
        chart_type_in          in varchar2,
        debug_xml_in           in varchar2,
        xml_filename_in        in varchar2,
        xml_output_dir_name_in in varchar2
    );

/*********************************************************************************/
    procedure create_xml_file_pr (
        chart_xml_text_in      in varchar2,
        xml_filename_in        in varchar2,
        xml_output_dir_name_in in varchar2
    );

/*********************************************************************************/
    procedure read_xml_file_pr (
        directory_in in varchar2,
        file_in      in varchar2
    );

/*********************************************************************************/
    procedure chart_licence_pr;

/*********************************************************************************/
   /* This function will return a list of values of available and supported
   chart types and can be included within the page in order to dynamicaly change
   the chart type. The query syntax is as follows:

               SELECT COLUMN_VALUE d, COLUMN_VALUE r
                 FROM TABLE (Chart_Pkg.chart_types_fn)

   */
    function chart_types_fn return chart_table_type;

/*********************************************************************************/

   /* This function will convert the string of templates into a table. Used to
      select the input value for templates for chart rendering within this package:

               SELECT COLUMN_VALUE custom_template
                 FROM TABLE (XML_Chart_Pkg.chart_string_into_table_fn)

   */
    function chart_templ_string_to_table_fn (
        p_string_in    in varchar2 default null,
        p_delimiter_in in varchar2 default ','
    ) return chart_table_type;

/*********************************************************************************/
    function chart_types_val_fn (
        chart_type_in in varchar2
    ) return boolean;

/*********************************************************************************/
    function check_directory_fn (
        xml_output_dir_name_in in varchar2
    ) return boolean;

/*********************************************************************************/
   /* Use this function to generate the code for calling the procedure.

     SELECT chart_pkg.get_chart_plsql FROM DUAL

   */
    function get_chart_plsql return varchar2;

/*********************************************************************************/
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
    );

/*********************************************************************************/
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
    );

/*********************************************************************************/
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
    );
/*********************************************************************************/
end xml_chart_pkg;
/

