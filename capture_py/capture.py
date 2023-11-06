import argparse
import pyautogui
from tkinter import PhotoImage, Tk, Canvas


def capture():
    parser = argparse.ArgumentParser()
    parser.add_argument('--color', '-c', default='blue')
    parser.add_argument('--fullscreen', '-f', default='./fullscreen.png')
    parser.add_argument('--capture', '-o', default='./capture.png')
    args = parser.parse_args()
    global root, canvas, rect_id, screenshot, color, fullscreen, capture
    color = args.color
    fullscreen = args.fullscreen
    capture = args.capture

    root = Tk()
    root.overrideredirect(True)

    screenshot = pyautogui.screenshot()
    screenshot.save(fullscreen)

    image = PhotoImage(file=fullscreen)
    canvas = Canvas(root, highlightthickness=0,
                    width=image.width(), height=image.height())
    canvas.create_image(0, 0, image=image, anchor="nw")
    canvas.pack(fill="both", expand=True)

    rect_id = None

    root.bind("<ButtonPress-1>", mouse_press)
    root.bind("<B1-Motion>", mouse_move)
    root.bind("<ButtonRelease-1>", mouse_release)

    root.mainloop()


def mouse_press(event):
    global start_x, start_y
    start_x = event.x
    start_y = event.y


def mouse_move(event):
    global start_x, start_y, rect_id
    end_x = event.x
    end_y = event.y

    if rect_id:
        canvas.delete(rect_id)

    rect_id = canvas.create_rectangle(
        start_x, start_y, end_x, end_y, outline=color, width=2)


def mouse_release(event):
    global start_x, start_y, screenshot
    end_x = event.x
    end_y = event.y

    if rect_id:
        canvas.delete(rect_id)

    if end_x != start_x and end_y != start_y:
        if end_x < start_x:
            start_x, end_x = end_x, start_x
        if end_y < start_y:
            start_y, end_y = end_y, start_y

        cropped_image = screenshot.crop((start_x, start_y, end_x, end_y))
        cropped_image.save(capture)
        root.destroy()


if __name__ == '__main__':
    capture()
