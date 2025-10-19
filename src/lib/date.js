import dayjs from 'dayjs';

export function format_db_date(date_input, date_type, show_year = true) {
  if (!date_input) return '';

  let date_str = '';
  if (typeof date_input === 'string') {
    date_str = date_input;
  } else if (date_input instanceof Date && typeof date_input.toISOString === 'function') {
    date_str = date_input.toISOString();
  } else if (typeof date_input === 'number') {
    // Nếu là timestamp dạng số
    date_str = new Date(date_input).toISOString();
  } else {
    // Nếu là object khác, thử ép sang string
    date_str = String(date_input);
  }

  // Parse bằng dayjs, chấp nhận cả DATE ('YYYY-MM-DD') lẫn DATETIME ('YYYY-MM-DD HH:mm:ss')
  const day_obj = dayjs(date_str);

  if (date_type === 'year') {
    return show_year ? day_obj.format('YYYY') : '';
  }
  else if (date_type === 'month') {
    return show_year
      ? day_obj.format('MMM YYYY')
      : day_obj.format('MMM');
  }
  else { // 'day' hoặc mặc định
    return show_year
      ? day_obj.format('DD MMM YYYY')
      : day_obj.format('DD MMM');
  }
}
