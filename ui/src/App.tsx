import './App.css'
import '@mantine/core/styles.css';
import '@mantine/notifications/styles.css';
import { MantineProvider } from '@mantine/core'
import { useNuiEvent } from './useNuiEvent'
import { notifications, Notifications } from '@mantine/notifications'

function App() {

  const colors = {
    info: 'blue',
    success: 'green',
    warn: 'yellow',
    error: 'red'
  }

  useNuiEvent("FS-Lib:notify", (data: { title: string, msg: string, duration: number, type?: 'info' | 'success' | 'warn' | 'error' }) => {
    let colorToUse = colors['info']

    if (data && data.type !== undefined) {
      colorToUse = colors[data.type];
    }

    console.log(colorToUse)
    console.log(data.type)

    notifications.show({
      title: data.title,
      message: data.msg,
      autoClose: data.duration * 1000,
      withCloseButton: false,
      radius: 'lg',
      withBorder: true,
      color: colorToUse,
      position: 'top-right'
    })
  })

  return (
    <MantineProvider forceColorScheme='dark'>
      <Notifications />
    </MantineProvider>
  )
}

export default App
