<?php
/**
 * Plugin Name: Prueba de comunicación Docker
 * Description: Inserta y lee un registro en MySQL para demostrar la comunicación entre los contenedores WordPress y MySQL.
 * Version: 1.0.0
 * Author: Equipo de trabajo
 */

if (!defined('ABSPATH')) {
    exit;
}

function entrega_docker_table_name(): string
{
    global $wpdb;
    return $wpdb->prefix . 'comunicacion_docker';
}

function entrega_docker_create_table(): void
{
    global $wpdb;

    $table = entrega_docker_table_name();
    $charset_collate = $wpdb->get_charset_collate();
    $sql = "CREATE TABLE IF NOT EXISTS {$table} (
        id BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
        mensaje VARCHAR(255) NOT NULL,
        creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id)
    ) {$charset_collate};";

    require_once ABSPATH . 'wp-admin/includes/upgrade.php';
    dbDelta($sql);
}

function entrega_docker_create_page(): void
{
    $page_id = (int) get_option('entrega_docker_page_id', 0);
    if ($page_id > 0 && get_post_status($page_id) === 'publish') {
        return;
    }

    $existing = get_page_by_path('prueba-comunicacion-docker');
    if ($existing instanceof WP_Post) {
        update_option('entrega_docker_page_id', $existing->ID);
        return;
    }

    $new_page_id = wp_insert_post(
        [
            'post_title' => 'Prueba de comunicación Docker',
            'post_name' => 'prueba-comunicacion-docker',
            'post_content' => '[prueba_docker]',
            'post_status' => 'publish',
            'post_type' => 'page',
        ],
        true
    );

    if (!is_wp_error($new_page_id)) {
        update_option('entrega_docker_page_id', (int) $new_page_id);
    }
}

function entrega_docker_setup(): void
{
    global $wpdb;

    $table = entrega_docker_table_name();
    $exists = $wpdb->get_var($wpdb->prepare('SHOW TABLES LIKE %s', $table));
    if ($exists !== $table) {
        entrega_docker_create_table();
    }

    entrega_docker_create_page();
}
add_action('init', 'entrega_docker_setup');

function entrega_docker_shortcode(): string
{
    global $wpdb;

    $table = entrega_docker_table_name();
    $mensaje = sprintf(
        'Registro creado desde %s a las %s',
        gethostname() ?: 'wordpress',
        current_time('mysql')
    );

    $inserted = $wpdb->insert($table, ['mensaje' => $mensaje], ['%s']);
    if ($inserted === false) {
        return '<div class="entrega-docker error"><p>No se pudo insertar el registro: '
            . esc_html($wpdb->last_error) . '</p></div>';
    }

    $id = (int) $wpdb->insert_id;
    $row = $wpdb->get_row($wpdb->prepare("SELECT * FROM {$table} WHERE id = %d", $id));
    $total = (int) $wpdb->get_var("SELECT COUNT(*) FROM {$table}");

    if (!$row) {
        return '<div class="entrega-docker error"><p>Se insertó el registro, pero no se pudo leer de vuelta.</p></div>';
    }

    ob_start();
    ?>
    <div class="entrega-docker" style="border:2px solid #2271b1;border-radius:8px;padding:20px;background:#f0f6fc;max-width:760px;">
        <h2 style="margin-top:0;">Comunicación WordPress ↔ MySQL verificada</h2>
        <p><strong>Contenedor de la aplicación:</strong> <?php echo esc_html(gethostname()); ?></p>
        <p><strong>Host de la base de datos:</strong> <?php echo esc_html(defined('DB_HOST') ? DB_HOST : 'no definido'); ?></p>
        <p><strong>Base de datos:</strong> <?php echo esc_html(defined('DB_NAME') ? DB_NAME : 'no definida'); ?></p>
        <p><strong>ID insertado:</strong> <?php echo esc_html((string) $id); ?></p>
        <p><strong>Mensaje guardado y leído:</strong> <?php echo esc_html($row->mensaje); ?></p>
        <p><strong>Fecha de creación:</strong> <?php echo esc_html($row->creado_en); ?></p>

        <p><strong>Total de registros en la tabla:</strong> <?php echo esc_html((string) $total); ?></p>
    </div>
    <?php
    return (string) ob_get_clean();
}
add_shortcode('prueba_docker', 'entrega_docker_shortcode');
