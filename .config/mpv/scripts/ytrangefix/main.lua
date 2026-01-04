--[[
Script mpv YouTube Proxy Cải tiến
Mục tiêu:
1. Chỉ chạy proxy nếu chưa có (mô hình Singleton).
2. Tách rời proxy khỏi mpv để nó không bị tắt khi mpv (đầu tiên) đóng.
3. Tất cả các phiên mpv đều sử dụng chung một proxy này.
--]]

local PROXY_ADDRESS = "http://127.0.0.1:12081"
local PROXY_PORT = "12081"

-- Biến toàn cục (trong script) để đảm bảo chúng ta chỉ thử khởi chạy proxy MỘT LẦN
-- cho mỗi phiên mpv (giảm thiểu việc cố gắng khởi chạy lặp lại không cần thiết).
local proxy_launch_attempted = false

-- Hàm helper để khởi chạy proxy
local function launch_proxy()
	local script_dir = mp.get_script_directory()
	local args = {
		script_dir .. "/http-ytproxy",
		"-c",
		script_dir .. "/cert.pem",
		"-k",
		script_dir .. "/key.pem",
		"-r",
		"10485760",
		"-p",
		PROXY_PORT,
	}

	mp.command_native_async({
		name = "subprocess",
		capture_stdout = false,

		-- QUAN TRỌNG:
		-- Bằng cách đặt là 'true' (hoặc không set, vì 'true' là mặc định),
		-- tiến trình proxy sẽ được TÁCH RỜI khỏi mpv.
		-- Nó sẽ KHÔNG bị giết khi mpv tắt.
		playback_only = true,

		args = args,
	})

	proxy_launch_attempted = true
end

-- Hàm helper để cấu hình mpv sử dụng proxy
local function set_mpv_proxy()
	mp.set_property("http-proxy", PROXY_ADDRESS)

	-- Tắt xác minh TLS là bắt buộc khi dùng proxy MITM cục bộ
	mp.set_property("tls-verify", "no")
end

-- Hàm khởi tạo chính
local function init()
	local url = mp.get_property("stream-open-filename")

	-- 1. Kiểm tra nếu là URL YouTube
	-- (Sử dụng 'string.match' để logic rõ ràng hơn)
	if not (url and url:match("^https:") and (url:match("youtu.be/") or url:match("youtube.com/"))) then
		-- Nếu không phải YouTube, không làm gì cả.
		return
	end

	-- 2. Kiểm tra nếu proxy bên ngoài đang được sử dụng
	local current_proxy = mp.get_property("http-proxy")
	if current_proxy and current_proxy ~= "" and current_proxy ~= PROXY_ADDRESS then
		-- Người dùng đang dùng proxy khác (ví dụ: proxy công ty).
		-- Không can thiệp.
		mp.osd_message("YouTube proxy: Đã phát hiện proxy tùy chỉnh. Bỏ qua.", 2)
		return
	end

	-- 3. Cố gắng khởi chạy proxy (nếu chưa thử trong phiên này)
	if not proxy_launch_attempted then
		-- Lệnh này sẽ chạy.
		-- Nếu cổng 12081 đã bị chiếm (do một phiên mpv khác đã chạy),
		-- lệnh này sẽ thất bại âm thầm, điều đó là BÌNH THƯỜNG.
		launch_proxy()
	end

	-- 4. LUÔN LUÔN thiết lập mpv để sử dụng proxy
	-- Dù lệnh launch_proxy() thành công hay thất bại,
	-- chúng ta vẫn luôn đặt mpv sử dụng proxy tại 12081.
	set_mpv_proxy()
end

-- SỬA ĐỔI QUAN TRỌNG:
-- Sử dụng 'on_load' thay vì 'start-file'.
-- Priority 10 (hoặc bất kỳ số nào < 50) đảm bảo nó chạy TRƯỚC khi
-- ytdl-hook (mặc định là priority 50) cố gắng phân giải URL.
mp.add_hook("on_load", 10, init)

-- (Không cần sự kiện "shutdown" vì proxy đã được tách rời)
